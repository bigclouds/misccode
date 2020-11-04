#!/usr/bin/python
#-*- coding:utf- -*-
'''
'''

import os,sys
import time
import json
import time
import smtplib
from sys import argv
from email.mime.text import MIMEText
from email.header import Header
from keystoneauth1 import identity
from keystoneauth1 import session
from neutronclient.v2_0 import client

STATE_OK = 0
STATE_WARNING = 1
STATE_CRITICAL = 2
PRE = 'vrouter-'
FMT ='%Y-%m-%dT%H:%M:%SZ'

host = 'smtp.163.com'
port = 465
sender = 'devops@163.com'
pwd = 'password'
receiver = ['devops@163.com','devops@163.com']
subject="OpenStack virtualrouter 告警"
"""
neutron virtualrouter-agent-list-hosting-virtualrouter router01_180129868
neutron virtualrouter-list --name=router01_180129868
neutron port-list --device_id=fb76e269-910e-46ea-97ec-17ff4071d317

neutron networkvirtualrouterbinding-list --virtualrouter_id=fb76e269-910e-46ea-97ec-17ff4071d317
neutron net-show fedd3f5d-ace4-413e-a2e6-402ee0208e59

neutron virtualrouterpublicip-list  --virtualrouter_id=fb76e269-910e-46ea-97ec-17ff4071d317
neutron virtualrouterpublicip-show 678e6663-0c0b-4e84-8b82-510227f069ba
"""

neutron = None
if os.environ.get('OS_USERNAME'):
    username=os.environ['OS_USERNAME']
    password=os.environ['OS_PASSWORD']
    tenant_name=os.environ['OS_TENANT_NAME']
    auth_url=os.environ['OS_AUTH_URL']
    region_name=os.environ['OS_REGION_NAME']
else:
    username='admin'
    password=''
    tenant_name='admin'
    user_domain_id='default'
    auth_url='http://102.20.5.161:5000/v2.0/'
    region_name='RegionOne'

def _netmask(mask_int):
    bin_arr = ['0' for i in range(32)]
    for i in range(mask_int):
      bin_arr[i] = '1'
    tmpmask = [''.join(bin_arr[i * 8:i * 8 + 8]) for i in range(4)]
    tmpmask = [str(int(tmpstr, 2)) for tmpstr in tmpmask]
    return '.'.join(tmpmask)

def check_host_alive(host):
    ping = "ping -q -c 3 %s >/dev/null 2>&1"
    ret = os.system(ping % host)
    if ret == 0:
        #print host , "is live"
        return True
    else:
        print host , "is not live"
        return False

def get_vr_nic_agent(host, vrns):
    try:
        n = os.popen("ssh %s ip netns exec %s python /usr/bin/nic.py" % (host, vrns)).read().strip()
        d = json.loads(n)
    except:
        os.popen("scp /usr/bin/nic.py root@%s:/usr/bin/nic.py" % (host)).read().strip()
    try:
        n = os.popen("ssh %s ip netns exec %s python /usr/bin/nic.py" % (host, vrns)).read().strip()
        d = json.loads(n)
    except:
        return None
    return d

def check_router(router, router_agents):
    # Inputs: router dict & all agents associated with the router
    # Outputs: STATE_CRITICAL if any bad agents were found
    # STATE_WARNING if no HA state found for l3 agent
    # STATE_OK if one and only one active agent
    # Checks each agent for one active & rest standby status
    # This is called onceer router
    search_opts = {'retrieve_all': True,}
    active_agent = False
    hosts = []
    hostsinfo = {}
    fips = []
    sbnets = []
    state = STATE_OK
    vr = {}
    vr['id'] = router['id']
    vrnetns = PRE+router['id']

    search_opts['virtualrouter_id'] = router['id']
    ips = neutron.list_virtualrouterpublicips(**search_opts)
    for ip in ips["virtualrouterpublicips"]:
        mask = _netmask(ip["mask"])
        tmp = {"id":ip["id"], "ip":ip["ip"],"mask":mask}
        fips.append(tmp)
    vr['fips'] = fips

    del search_opts['virtualrouter_id']
    search_opts['device_id'] = router['id']
    subnets = neutron.list_ports(**search_opts)
    for sn in subnets["ports"]:
        if len(sn["fixed_ips"]) > 0:
            for n in sn["fixed_ips"]:
                tmp = {}
                t = neutron.show_subnet(subnet=n["subnet_id"])
        	mask = _netmask(int(t["subnet"]["cidr"].partition("/")[2]))
                tmp = {'port':sn['id'], "id":t["subnet"]["id"], "mask":mask, "gateway_ip":t["subnet"]["gateway_ip"]}
                sbnets.append(tmp)
    vr['subnets'] = sbnets

    for agent in router_agents['agents']:
        hosts.append(agent["host"].partition(".netns")[0])
        if 'ha_state' not in agent.keys():
            print("WARNING: No HA state for vr %s of l3 agent %s" % (router['id'], agent['id']))
            state = STATE_WARNING
        if active_agent and agent['ha_state'] == 'active':
            print("ERROR: Multiple active l3 agents on router %s" % router['id'])
            state = STATE_CRITICAL
        if agent['ha_state'] == 'active':
            active_agent = True

    if not active_agent:
        print("ERROR: No active l3 agents for router %s" % router['id'])
        state = STATE_CRITICAL
    if len(hosts) < 2:
        print("ERROR: not enough agents found for router %s, hosts %s" % router['id'], hosts)
        return STATE_CRITICAL

    #print hosts, fips
    master = 0
    masterh = ""
    scores = []
    maxh = -1
    activeh = ""
    havip = ""
    print "-----%s-----" % router['name']
    print router['name'], router['id'], hosts
    for h in hosts:
        tmp = {}
        i = 0
        alive = check_host_alive(h)
        nic = get_vr_nic_agent(h, vrnetns)
        if nic == None:
            print "%s no nic.py, please install OpenStackVirtualRouter rpm" % h
            return STATE_WARNING
        for k, v in nic.items():
            i += len(v)
            if k.startswith("ha-"):
                if len(v) == 2:
                    master += 1
                    tmp["active"] = True
                    masterh = h
                    havip = v[1]
                else:
                    tmp["active"] = False
        scores.append(i)
        if i > maxh:
            activeh = h
            maxh = i
        tmp['score'] = i
        tmp['name'] = h
        tmp['nic'] = nic
        tmp['alive'] = alive
        hostsinfo[h] = tmp
    if master == 2:
        print("ERROR: HA state of vr %s, two active" % router['id'])
    elif master == 0:
        print("ERROR: HA state of vr %s, two standby" % router['id'])
    else:# master == 1:
        print("OK: HA state of vr %s name %s, active agent %s" % (router['id'], router['name'], masterh))
    vr['hosts'] = hostsinfo
    activeindex=hosts.index(activeh)
    #print "max ips %d, active %s, index %d" % (maxh, activeh, activeindex) 
    #print scores, vr
    if master == 2 or master == 0 or master == 1:
        for h in hosts:
            if not h == activeh: #standby
                #print("ssh %s ip netns exec %s python /usr/bin/nic.py clean" % (h, vrnetns))
                devs = "qr-" + router['id'][0:11]
                nic = hostsinfo[h]['nic'].get(devs)
                for pip in fips:
                    if nic == None:
                        break
                    ip = "%s/%s" % (pip['ip'], pip['mask'])
                    try:
                        nic.index(ip)
                    except:
                        pass
                    else:
                        state = STATE_CRITICAL
                        print("ssh %s ip netns exec %s ip addr del %s dev %s" % (h, vrnetns, ip, devs))
                for n in sbnets:
                    ip = "%s/%s" % (n['gateway_ip'], n['mask'])
                    devs = "qr-" + n['port'][0:11]
                    nic = hostsinfo[h]['nic'].get(devs)
                    if nic == None:
                        continue
                    try:
                        nic.index(ip)
                    except:
                        pass
                    else:
                        state = STATE_CRITICAL
                        print("ssh %s ip netns exec %s ip addr del %s dev %s" % (h, vrnetns, ip, devs))
                nics = hostsinfo[h]['nic']
                have_ha_nic = False
	        for n in nics:
                    if n.startswith("ha-"):
                        have_ha_nic = True
                        nic = hostsinfo[h]['nic'].get(n)
                        if nic == None or len(nic) == 0:
                            have_ha_nic = False
                        if len(nic) > 1:
                            state = STATE_CRITICAL
                            print("ssh %s ip netns exec %s ip addr del %s dev %s" % (h, vrnetns, nic[1], n))
                        else: # dry run
                            pass
                            #print("OK find:ssh %s ip netns exec %s ip addr del %s dev %s" % (h, vrnetns, havip, n))
                        break
                if not have_ha_nic:
                    state = STATE_CRITICAL
                    print("ERROR:ssh %s ip netns exec %s ip addr; ha nic lost or no ip" % (h, vrnetns))
            else:
                # fips
                devs = "qr-" + router['id'][0:11]
                nic = hostsinfo[h]['nic'][devs]
                for pip in fips:
                    ip = "%s/%s" % (pip['ip'], pip['mask'])
                    try:
                        nic.index(ip)
                    except:
                        print("ssh %s ip netns exec %s ip addr add %s dev %s" % (h, vrnetns, ip, devs))
                        print("ssh %s ip netns exec %s arping -c 3 -A -I %s -b -s %s 0.0.0.0" % (h, vrnetns, devs, pip['ip']))
                    else: # dry run
                        pass
                # fixed ip

                for n in sbnets:
                    ip = "%s/%s" % (n['gateway_ip'], n['mask'])
                    devs = "qr-" + n['port'][0:11]
                    nic = hostsinfo[h]['nic'][devs]
                    try:
                        nic.index(ip)
                    except:
                        print("ssh %s ip netns exec %s ip addr add %s dev %s" % (h, vrnetns, ip, devs))
                        print("ssh %s ip netns exec %s arping -c 3 -A -I %s -b -s %s 0.0.0.0" % (h, vrnetns, devs, n['gateway_ip']))
                    else: # dry run
                        pass

                nics = hostsinfo[h]['nic']
                have_ha_nic = False
	        for n in nics:
                    if n.startswith("ha-"):
                        have_ha_nic = True
                        nic = hostsinfo[h]['nic'][n]
                        #print nic, havip
                        try:
                            nic.index(havip)
                        except:
                            print("ssh %s ip netns exec %s ip addr add %s dev %s" % (h, vrnetns, havip, n))
                        else: # dry run
                            pass
                        break         
                if not have_ha_nic:
                    state = STATE_CRITICAL
                    print("ERROR:ssh %s ip netns exec %s ip addr; ha nic lost or no ip" % (h, vrnetns))
    print "-----%s-----" % router['name']
    return state

def sentemail(subject, body):
    msg = MIMEText(body, 'html', 'utf-8')
    msg['subject'] = Header(subject, 'utf-8')
    msg['from'] = sender
    msg['to'] = ''.join(receiver)
    try:
        t = time.strftime('%Y-%m-%d %H:%M:%S')
        s = smtplib.SMTP_SSL(host, port)
        s.login(sender, pwd)
        s.sendmail(sender, receiver, msg.as_string())
        #print ('sent email success %s' % t)
    except smtplib.SMTPException:
        pass
        #print ('sent email fail %s' % t)

def help():
    print """
%s --all  		# iterate and check all vrs
%s vr1 vr2 .. vrn   	# only specified vrs are checked
          """ % (argv[0], argv[0])

exclude=[]
def main():
    badvr = []
    agent_status = STATE_OK
    search_opts = {'all_tenants': True,}

    if len(argv) == 1 or len(argv) >= 2 and argv[1] == "help":
        help()
        sys.exit(0)

    if len(argv) > 1:
        for i in range(1, len(argv)):
            exclude.append(argv[i])
    global neutron
    neutron = client.Client(username=username, password=password, tenant_name=tenant_name, auth_url=auth_url,region_name=region_name)
    vr =  neutron.list_virtualrouters()

    for router in vr['virtualrouters']:
        if len(exclude) > 0 and argv[1] != "--all":
            try:
               exclude.index(router["name"])
            except:
               continue
        if not router["ha_mode"]:
            continue
        time.sleep(1)
        search_opts['virtualrouter'] = router['id']
        router_agents = neutron.list_virtualrouter_agent_hosting_virtualrouters(**search_opts)
        agent_status = check_router(router, router_agents)
        if agent_status == STATE_CRITICAL or agent_status == STATE_WARNING:
	    badvr.append(router['id'])

    if len(badvr) > 0:
        print("ERROR: ", badvr)
        sentemail(subject, "\t,\t".join(badvr))
        sys.exit(STATE_CRITICAL)
    else:
        print("OK: No routers with multiple active or all standby state")
        sys.exit(STATE_OK)

if __name__ == "__main__":
    main()

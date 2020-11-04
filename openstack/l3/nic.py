import psutil
import json
from sys import argv

def get_netcard():
   netcard_info = {}
   info = psutil.net_if_addrs()
   for k,v in info.items():
       ips=[]
       for item in v:
           if item[0] == 2 and not item[1]=='127.0.0.1':
               ips.append("%s/%s" % (item[1],item[2]))
       if len(ips) > 0:
           netcard_info[k] = ips
   return netcard_info
if __name__ == '__main__':
    nics = get_netcard()
    cmd = []
    pre = "ip addr del %s dev %s"
    if len(argv)>1 and argv[1] == "clean":
        for k, v in nics.items():
            if k.startswith("qr-"):
                for ip in v:
                    cmd.append(pre % (ip, k))
                continue
            if k.startswith("ha-"):
                if len(v) == 2:
                    cmd.append(pre % (v[1], k))
    if len(cmd) > 0:
        print cmd
    else:
        print json.dumps(nics)

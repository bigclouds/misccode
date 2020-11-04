# test_IPV4_DeviceC.py
# -*- coding: utf-8 -*-
import sys
import logging 
from ncclient import manager
from ncclient import operations

# 将接口切换为三层口
L3_INTERFACE = '''<config>
 <ethernet xmlns="http://www.huawei.com/netconf/vrp" content-version="1.0" format-version="1.0">
 <ethernetIfs>
 <ethernetIf>
 <ifName>10GE1/0/1</ifName>
 <l2Enable>disable</l2Enable>
 </ethernetIf>
 </ethernetIfs>
 </ethernet>
</config>'''

# 配置interface1的IPv4地址。
IPV4_CONFIG = '''<config>
 <ifm xmlns="http://www.huawei.com/netconf/vrp" content-version="1.0" format-version="1.0">
 <interfaces>
 <interface>
 <ifName>10GE1/0/1</ifName>
 <ifAdminStatus>up</ifAdminStatus>
 <ipv4Config>
 <addrCfgType>config</addrCfgType>
 <am4CfgAddrs>
 <am4CfgAddr>
 <ifIpAddr>1.1.4.6</ifIpAddr>
 <subnetMask>255.255.255.252</subnetMask>
 <addrType>main</addrType>
 </am4CfgAddr>
  </am4CfgAddrs>
 </ipv4Config>
 </interface>
 </interfaces>
 </ifm>
 </config>'''

# 配置IPv4静态路由。
IPV4_NEXTHOP = '''<config>
 <staticrt xmlns="http://www.huawei.com/netconf/vrp" content-version="1.0" format-version="1.0">
 <staticrtbase>
 <srRoutes>
 <srRoute>
 <vrfName>_public_</vrfName>
 <afType>ipv4unicast</afType>
 <topologyName>base</topologyName>
 <prefix>1.1.4.1</prefix>
 <maskLength>30</maskLength>
 <ifName>10GE1/0/1</ifName>
 <destVrfName>_public_</destVrfName>
 <nexthop>1.1.4.5</nexthop>
 </srRoute>
 </srRoutes>
 </staticrtbase>
 </staticrt>
 </config>'''

# 检查配置结果。
GET_INTERFACE = '''
 <ifm xmlns="http://www.huawei.com/netconf/vrp" content-version="1.0" format-version="1.0">
 <interfaces>
 <interface>
 <ifName>10GE1/0/1</ifName>
 <ifAdminStatus></ifAdminStatus>
 <ipv4Config>
 <addrCfgType></addrCfgType>
 <am4CfgAddrs>
 <am4CfgAddr>
 <ifIpAddr></ifIpAddr>
 <subnetMask></subnetMask>
 <addrType></addrType>
 </am4CfgAddr>
 </am4CfgAddrs>
 </ipv4Config>
 </interface>
 </interfaces>
 </ifm>
 '''
GET_STATICRT = '''
 <staticrt xmlns="http://www.huawei.com/netconf/vrp" content-version="1.0" format-version="1.0">
 <staticrtbase>
 <srRoutes>
 <srRoute>
 <vrfName/>
 <afType/>
 <topologyName/>
 <prefix/>
 <maskLength/>
 <destVrfName/>
 <nexthop/>
 </srRoute>
 </srRoutes>
 </staticrtbase>
 </staticrt>
'''

# 建立连接，创建NETCONF会话。
def huawei_connect(host, port, user, password):
    return manager.connect(host=host,
    port=port,
    username=user,
    password=password,
    hostkey_verify = False,
    device_params={'name': "huawei"},
    allow_agent = False,
    look_for_keys = False)

def _check_response(rpc_obj, snippet_name):
    print("RPCReply for %s is %s" % (snippet_name, rpc_obj.xml))
    xml_str = rpc_obj.xml
    if "<ok/>" in xml_str:
        print("%s successful" % snippet_name)
    else:
        print("Cannot successfully execute: %s" % snippet_name)

def test_IPV4_DeviceC(host, port, user, password):
    # 1.建立连接，创建NETCONF会话
    with huawei_connect(host, port=port, user=user, password=password) as m:
        # 2.配置interface1的IPv4地址
        rpc_obj = m.edit_config(target='running', config=L3_INTERFACE)
        _check_response(rpc_obj, 'L3_INTERFACE')
        rpc_obj = m.edit_config(target='running', config=IPV4_CONFIG)
        _check_response(rpc_obj, 'IPV4_CONFIG')
        # 3.配置IPv4静态路由
        rpc_obj = m.edit_config(target='running', config=IPV4_NEXTHOP)
        _check_response(rpc_obj, 'IPV4_NEXTHOP')
        # 4.检查配置结果
        get_interface = m.get(("subtree", GET_INTERFACE)).data_xml
        print(get_interface)
        get_staticrt = m.get(("subtree", GET_STATICRT)).data_xml
        print(get_staticrt)

    with open("%s.xml" % host, 'w') as f:
        f.write(get_interface)
        f.write(get_staticrt)

if __name__ == '__main__':
    test_IPV4_DeviceC(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])

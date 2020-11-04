# -*- coding: utf-8 -*-
import sys
from ncclient import manager
from ncclient import operations

username="sdn_test"
password="Qaz@12345"
#python huawei-connect-1.py 100.1.1.1 830 client001 Hello-huawei123
def huawei_connect(host, port, user, password):
    return manager.connect(host=host,
                            port=port,
                            username="sdn_test",
                            password="Qaz@12345",
                            hostkey_verify = False,
                            device_params={'name': "huawei"},
                            allow_agent = False,
                            look_for_keys = False)

def test_connect(host, port, user, password):
    with huawei_connect(host, port=port, user=user, password=password) as m:
        n = m._session.id 
        print("The session id is %s." % (n))

if __name__ == '__main__':
    test_connect(sys.argv[1], sys.argv[2], username, password)

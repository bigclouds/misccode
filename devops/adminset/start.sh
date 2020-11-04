#!/bin/bash

#下载镜像命令：docker pull ppabc/adminset

#使用方法： 
docker run -d --name adminset12 -p 8090:80 --privileged  ppabc/adminset
#docker exec -it adminset12  /bin/bash /opt/start.sh

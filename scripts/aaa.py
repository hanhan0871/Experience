#!/usr/bin/python
#-*- coding: UTF-8 -*-
import subprocess
import sys

svr = sys.argv[1]
v = sys.argv[2]

command = "ansible " + svr + " -m shell -a " + "'grep -i " + v + " /opt/tomcat/node*/logs/catalina.out'"
process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=None, shell=True)
results = process.stdout.readlines()
for result in results:
    print result

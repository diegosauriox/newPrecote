from obspy import UTCDateTime
from obspy.clients.earthworm import Client
from MySQL_comandos import *
from datenum import *
import os
import time
with open('conf.txt') as f:
    lines = f.readlines()
i=0

while i<4:
    j=-1
    for line in lines:
        j=j+1
        if line=="hostWWs=\n":
            hostWWS=lines[j+1][0:-1]
            i=i+1
        if line=="portWWS=\n":
            portWWS=lines[j+1][0:-1]
            i=i+1
        if line=="inicio=\n":
            inicio=lines[j+1][0:-1]
            i=i+1
        if line=="fin=\n":
            fin=lines[j+1][0:-1]
            i=i+1
        if line=="hostWWs=\n":
            hostWWS=lines[j+1][0:-1]
            i=i+1

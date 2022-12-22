from obspy import UTCDateTime
from obspy.clients.earthworm import Client
from MySQL_comandos import *
from datenum import *
import os
import time
import mysql.connector

with open('conf.txt') as f:
    lines = f.readlines()
i=0




while i<12:
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
        if line=="user=\n":
            user=lines[j+1][0:-1]
            i=i+1
        if line=="pass=\n":
            password=lines[j+1][0:-1]
            i=i+1
        if line=="db=\n":
            db=lines[j+1][0:-1]
            i=i+1
        if line=="macro_sec=\n":
            macro_sec=lines[j+1][0:-1]
            i=i+1
        if line=="est_val=\n":
            est_val=lines[j+1][0:-1]
            i=i+1
        if line=="macro_sec=\n":
            macro_sec=lines[j+1][0:-1]
            i=i+1
        if line=="host=\n":
            host=lines[j+1][0:-1]
            i=i+1

mydb = mysql.connector.connect(
  host=host,
  user=user,
  password=password,
  database=db
)


t1			=	UTCDateTime(t1)
t2			=	UTCDateTime(t2)
tt1=t1-60
tt2=t2+60
ttt1=datetime_to_datenum(tt1.strftime("%Y-%m-%d %H:%M:%S"))
ttt2=datetime_to_datenum(tt2.strftime("%Y-%m-%d %H:%M:%S"))

texto='select * from identificacion_senal where inicio between '+str(ttt1)+' AND '+str(ttt2)
eventos=query(texto,visualizar='nones')
client = Client(hostWWS, int(portWWS),timeout=15)

query2='SELECT cod_event FROM ufro_ovdas_v1.avistamiento_registro;'
query1='SELECT * FROM ufro_ovdas_v1.identificacion_senal WHERE inicio BETWEEN '+ str(inicio) +' AND ' + str(fin)+' ORDER BY inicio ASC;'


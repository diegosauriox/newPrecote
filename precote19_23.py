from obspy import UTCDateTime
from obspy.clients.earthworm import Client
from MySQL_comandos import *
from datenum import *
import os
import time
with open('conf.txt') as f:
    lines = f.readlines()
i=0

dir='/sacs'


while i<4:
	j=-1
	for line in lines:
		j=j+1
		if line=='hostWWS=\n':
			hostWWS=lines[j+1][0:-1]
			i=i+1
		if line=='portWWS=\n':
			portWWS=lines[j+1][0:-1]
			i=i+1
		if line=='inicio=\n':
			t1=lines[j+1][0:-1]
			i=i+1
		if line=='fin=\n':
			t2=lines[j+1][0:-1]
			i=i+1

#print(lines)
retroceso=15


###############################################################################
###############################################################################
###############################################################################
# 2021-08-22 12:00:00.000
# itera desde las 19 a las 23.58.00 #porque le suma un minuto

"""
t1lista1=list(t1)
t1lista1[11]='1'
t1lista1[12]='9'
t1lista2=list(t2)
t1lista2[11]='2'
t1lista2[12]='3'
t1lista2[14]='5'
t1lista2[15]='8'
t1lista2[17]='5'
t1lista2[18]='9'
t1tmp="".join(t1lista1)
t2tmp="".join(t1lista2)
print(t1tmp)
print(t2tmp)
t1tmp			=	UTCDateTime(t1tmp)
t2tmp			=	UTCDateTime(t2tmp)
tt1=t1tmp-60
tt2=t2tmp+60

ttt1=datetime_to_datenum(tt1.strftime("%Y-%m-%d %H:%M:%S"))
ttt2=datetime_to_datenum(tt2.strftime("%Y-%m-%d %H:%M:%S"))
print("fechas")
print(ttt1)
print(ttt2)
texto='select * from identificacion_senal where inicio between '+str(ttt1)+' AND '+str(ttt2)
eventos=query(texto,visualizar='nones')

client = Client(hostWWS, int(portWWS),timeout=15)
for evento in eventos:
	estacion=evento[3]+'Z'
	#informacion = client.get_availability(station=estacion)
	#DatosZ=informacion[0]
	time1=UTCDateTime(datenum_to_datetime(evento[14]))-5
	time2=UTCDateTime(datenum_to_datetime(evento[14]))+55
	try:
		#st = client.get_waveforms(DatosZ[0],DatosZ[1],DatosZ[2],DatosZ[3],time1,time2)
                st = client.get_waveforms('TC',estacion,'99','HHZ',time1,time2)
                print('ejecuta 19')
                name=evento[0][0:17]+'_'+evento[0][18:20]+'_'+evento[0][21:23]+'_'+evento[0][24:]+'.SAC'
                st[0].write('sacs/'+name,format='SAC')
                print(name)

	except Exception as inst:
		print(type(inst))    # the exception instance
		print(inst.args)     # arguments stored in .args
		print(inst)        		
		print('Error SACS')    		
	time.sleep(2)
"""


###############################################################################
###############################################################################
###############################################################################



t1			=	UTCDateTime(t1)
t2			=	UTCDateTime(t2)
tt1=t1-60
tt2=t2+60
ttt1=datetime_to_datenum(tt1.strftime("%Y-%m-%d %H:%M:%S"))
ttt2=datetime_to_datenum(tt2.strftime("%Y-%m-%d %H:%M:%S"))


texto='select * from identificacion_senal where inicio between '+str(ttt1)+' AND '+str(ttt2)
eventos=query(texto,visualizar='nones')
###############################################################################

client = Client(hostWWS, int(portWWS),timeout=15)
for evento in eventos:
	#if evento[3]=="LBN":
	#	pass
	#else:
	estacion=evento[3]+'Z'
	#informacion = client.get_availability(station=estacion)
	#DatosZ=informacion[0]
	time1=UTCDateTime(datenum_to_datetime(evento[14]))-5
	time2=UTCDateTime(datenum_to_datetime(evento[14]))+55
	try:
                st = client.get_waveforms('TC',estacion,'99','HHZ',time1,time2)
                name=evento[0][0:17]+'_'+evento[0][18:20]+'_'+evento[0][21:23]+'_'+evento[0][24:]+'.SAC'
                st[0].write('sacs/'+name,format='SAC')
                print(name)
	except Exception as inst:
		print(type(inst))    # the exception instance
		print(inst.args)     # arguments stored in .args
		print(inst)
		print('Error SACS')
	time.sleep(1)



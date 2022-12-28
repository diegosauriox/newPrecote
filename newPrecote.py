from obspy import UTCDateTime
import math
from obspy.clients.earthworm import Client
from MySQL_comandos import *
from datenum import *
import os
import time
import mysql.connector
import numpy
from scipy import signal
with open('conf.txt') as f:
    lines = f.readlines()
i=0

def ismember(d, k):
  return [1 if (i == k) else 0 for i in d]

def butter_bandpass_lfilter(data, lowcut, highcut, fs, order=6):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = signal.lfilter(b, a, data)
    return y

def butter_bandpass(lowcut, highcut, fs, order=10):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = signal.butter(order, [low, high], btype='band')
    return b, a
def waveP(y):
    ws=400
    wl=400
    lim_inf=.05
    y_ef=y
    LV=numpy.array([max(abs(y_ef[i-wl:i])) for i in range(wl+1,len(y_ef)-ws)])
    RV=numpy.array([max(abs(y_ef[i:i+ws])) for i in range(wl+1,len(y_ef)-ws)])
    stmltm=RV/(LV+lim_inf)
    i=numpy.argwhere(numpy.array(stmltm)==max(stmltm))
    return i[-1]

def waveS(y):
    fs=100
    f, t, Sxx = signal.spectrogram(y, fs,numpyerseg=300,noverlap=299)
    S=pow(abs(Sxx),2)

    Sn=(S-S.min())/(S.max()-S.min());
    #Sn_db=10*numpy.log10(Sn);
    u=Sn.mean()
    B=Sn>=u
    Su=Sn*B
    #Su_db=10*numpy.log10(Su)

    K=len(f)
    Ev=Su.sum(axis=0)
    Evn=Ev-Ev.min()/(Ev.max()-Ev.min())

    v=B.sum(axis=0)
    vn=v-v.min()/(v.max()-v.min())

    SE=vn*Evn
    SEm=SE/SE.max()

    p=numpy.cumsum(SE)/SE.sum()
    p_f= gaussian_filter1d(p, 25)

    p_d=numpy.gradient(p_f)
    p_dd=numpy.gradient(p_d)

    i=numpy.argwhere(numpy.array(p_dd)==max(p_dd))
    ts=numpy.round(t[i[-1]]*100)
    return ts


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

cursor=mydb.cursor()
data_query1=cursor.execute(query1)
data_query2=cursor.execute(query2)
code_event1=data_query1[:,1]
code_event2=data_query2

cursor.close()

table1=data_query1

if len(code_event2)>0:
    im=ismember(code_event1,code_event2)
    table1[im,:]=[]

if len(table1)==0:
    print("Ya se analizaron los eventos correspondientes a ese periodo")

inicio=table1.inicio
estacion=table1.est
hayTrazas=numpy.zeros(1,len(table1))
trazas_vacias=0

cursor=mydb.cursor()

t1			=	UTCDateTime(t1)
t2			=	UTCDateTime(t2)
tt1=t1-60
tt2=t2+60
ttt1=datetime_to_datenum(tt1.strftime("%Y-%m-%d %H:%M:%S"))
ttt2=datetime_to_datenum(tt2.strftime("%Y-%m-%d %H:%M:%S"))

query1='select * from identificacion_senal where inicio between '+str(ttt1)+' AND '+str(ttt2)
eventos=cursor.execute(query1)
client = Client(hostWWS, int(portWWS),timeout=15)
evento_i={}
ondaP=[]
eventoSolito=[]
for evento in eventos:
    estacion=evento[3]+'Z'
    evento_i.esta=estacion
    time1=UTCDateTime(datenum_to_datetime(evento[14]))-5
    time2=UTCDateTime(datenum_to_datetime(evento[14]))+55
    try:
        st = client.get_waveforms('TC',estacion,'99','HHZ',time1,time2)
        st=st.filter(type='highpass',freq =0.8)
        st.merge()
        st=st.slice(UTCDateTime(time1),UTCDateTime(time2))
        traza=st[0]
        tracita=[traza.data,traza.times("timestamp")]
        #sacar data de st
        yraw=traza
        evento_i.time=tracita
    except:
        pass
    if numpy.std(yraw)==0:
        evento_i.onda_P=0
        evento_i.onda_S=0
        evento_i.snr=0
        evento_i.frec=0
        evento_i.amp=0
        trazas_vacias=trazas_vacias+1
    else:
        hayTrazas[i]=1
        y_l,yf=butter_bandpass_lfilter(yraw,1,10,100)
        if len(y_l)>3000:
            y=y_l[1:3000]
        else:
            y=y_l
        if len(y)<700:
            tP=0
            tS=0
            evento_i.onda_P=tP
            evento_i.onda_S=tS
            ondaP[i]=""
            evento_i.snr=0
            evento_i.frec=0
            evento_i.amp=max(abs(yf))
        else:
            iP=waveP(y)
            iS=waveS(y)
            if iS<=iP:
                #no me acuerdo si es ip:-1 o ip:
                iS2=waveS(y[iP:])
                iS=iS2+iP
            if iP>0:
                tp=evento_i.time(iP)
            else:
                tP=0
            if iS>0:
                tS=evento_i.time(iS)
            else:
                tS=0
            evento_i.onda_P=tP
            evento_i.onda_S=tS
            ondaP[i]=tP
            evento_i.snr=10*math.log10(abs(numpy.mean(math.pow(y[iP+50:-100],2))))/numpy.mean(math.pow(y[101:iP-100],2))
            #transformar el .m de frecuencia
            evento_i.frec=""
            evento_i.amp=max(abs(yf))
    time.sleep(1)
    evento_i.volc=table1.volcan[i]
    evento_i.code=table1.cod_event[i]
    evento_i.crdt=table1.created_at(i)
    evento_i.pk=table1.cod_event_in(i)
    evento_i.coda=table1.fin(i)
    evento_i.comp=chr(table1.componente[i])
    evento_i.label=chr(table1.label_event[i])
    evento_i.inicio=(table1.inicio(i))
    eventoSolito[i]=evento_i
if sum(hayTrazas)==0:
    print("problema con trazas")
#nose como pasar el datenum a python
th=""
ondaP_sorted=numpy.sort(ondaP,axis=1)
i_sorted=numpy.argsort(ondaP,axis=1)

filt_nan=i_sorted[numpy.sum(ondaP==0)+1:numpy.sum(numpy.isnan(ondaP))]
#NO ENTIENDO ESE ":"
eventoSolito_sorted[:]=eventoSolito[filt_nan]
ondaP_sorted2[:]=ondaP[filt_nan]

ondaP_sorted=ondaP_sorted2 

i_estacion=numpy.full(len(estacion))

k=0
i=1
macro=[]
t_macro=[]
while i<=len(eventoSolito_sorted):
    t_in=ondaP_sorted[i]
    if t_in>0:
        t_th=t_in+th
    k=k+1
    while ondaP_sorted[i]<=t_th:
       macro[i]=k
       t_macro[i]=t_in 
       i=i+1
       if i>numpy.sum(numpy.isnan(ondaP_sorted)):
        break
    else:
        i=i+1

rgb=
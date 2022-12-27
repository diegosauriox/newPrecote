
conn= MysqlConn(host,user,pass,db);
inicio2=timestamp(inicio)
fin2=timestamp(fin)

que1=['SELECT * FROM ufro_ovdas_v1.identificacion_senal'...
    ' WHERE inicio BETWEEN ' num2str(inicio2) ' AND ' num2str(fin2) ...
    ' ORDER BY inicio ASC;'];curs1=exec(conn,que1);
if(isfield(curs1,'Message'))
    error(curs1.Message)
end
curs1  = fetch(curs1);
asd=fetch(conn,que1);
close(conn)


%%

UTC_epoch_seconds=    1512102840.63134;
UTC_epoch_seconds= 1517477275.88931;
UTC_offset=UTC_epoch_seconds/(24*60*60);
atomTime=UTC_offset+datenum(1970,1,1);
datetime(atomTime,'ConvertFrom','datenum')

%%
aT=datenum('2018-02-01 07:00:00.000');
UTC_offset=dn-datenum(1970,1,1);
UTC_ep_s=UTC_offset*(24*60*60)
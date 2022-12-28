clc
clear
javaaddpath('mysql-connector-java-5.1.48-bin.jar')
fid = fopen('conf.txt');
cell_data= textscan(fid,'%s','Delimiter','\n');
my_data = cat(2,cell_data{:});
fclose(fid);
itext=find(strcmp(my_data,'user='));
user=my_data{itext+1};
itext=find(strcmp(my_data,'pass='));
pass=my_data{itext+1};
itext=find(strcmp(my_data,'db='));
db=my_data{itext+1};
itext=find(strcmp(my_data,'host='));
host=my_data{itext+1};
itext=find(strcmp(my_data,'hostWWS='));
host_wws=my_data{itext+1};
itext=find(strcmp(my_data,'portWWS='));
port_wws=str2double(my_data{itext+1});
try
   itext=find(strcmp(my_data,'macro_sec='));
   macro_sec=str2double(my_data{itext+1});
catch
   error('Error en archivo configuración. Variable macro_sec')
end
itext=find(strcmp(my_data,'est_val='));
est_val=strsplit(my_data{itext+1},',');
itext=find(strcmp(my_data,'inicio='));
in_str=my_data{itext+1};
itext=find(strcmp(my_data,'fin='));
fn_str=my_data{itext+1};
s_th=datenum(0,0,0,0,1,0);
r_in=datenum(in_str,'yyyy-mm-dd HH:MM:SS.FFF');
r_fn=datenum(fn_str,'yyyy-mm-dd HH:MM:SS.FFF');
inicio=datenum(in_str,'yyyy-mm-dd HH:MM:SS.FFF')-s_th;
fin=datenum(fn_str,'yyyy-mm-dd HH:MM:SS.FFF'+s_th);
%%
conn= MysqlConn(host,user,pass,db);
que2='SELECT cod_event FROM ufro_ovdas_v1.avistamiento_registro';
que1=['SELECT * FROM ufro_ovdas_v1.identificacion_senal'...
   ' WHERE inicio BETWEEN ' num2str(inicio) ' AND ' num2str(fin) ...
   ' ORDER BY inicio ASC;'];
  ###################################### 
curs1=exec(conn,que1);
if(isfield(curs1,'Message'))
   error(curs1.Message)
end
curs1  = fetch(curs1);
curs2=exec(conn,que2);
curs2  = fetch(curs2);
table1_all=fetch(conn,que1);
cod_event1=table1_all(:,1);
cod_event2=fetch(conn,que2);
close(conn)
%%
table1=table1_all;
//TABLA 1 tomar solo los que nos estan en la t2
if height(cod_event2)>0
   im=ismember(cod_event1,cod_event2); %Eventos que ya están en tabla 2
   table1(im,:)=[];
end

if(height(table1)==0)
   error('Ya se analizaron los eventos correspondientes a ese periodo')
end

%%
//filtro raro
filtro = load('Filtro_pasabanda_1_10_orden10.mat');
%% Leer trazas
%% Leer BD y detección PS
inicio_=table1.inicio;
estacion_=table1.est;
hayTrazas=zeros(1,height(table1));
trazas_vacias=0;
disp('Busca Archivos...')
for i=1:height(table1)
   % date_str=char(table1.cod_event(i));
   % t1=datenum(date_str(5:end),'dd-mm-yyyy_HH:MM:SS.FFF');
   %   t1=inicio_(i)-seconds(5);
   estacion_i=char(estacion_(i));
   event_i.esta=estacion_i;
   %Leer trazas

   sac_name=table1.cod_event{i};
   sac_name=replace(sac_name,'.','_');
   sac_name=replace(sac_name,':','_');
   disp(['sacs/' sac_name '.SAC'])
   try
       eventi=rdsac(['sacs/' sac_name '.SAC']);
       yraw=eventi.d;
       event_i.time=eventi.t;
   catch
       yraw=0;
       event_i.time=0;
   end
   //asignar p o s =0
   if std(yraw)==0
       event_i.onda_P=0;
       event_i.onda_S=0;
    % ondaP_(i)=0;
       event_i.snr=0;
       event_i.frec=0;
       event_i.amp=0;
       trazas_vacias=trazas_vacias+1;
   else
       hayTrazas(i)=1;
       //preprocesamiento 
       [y_l,yf]=prePro(yraw,filtro,0);
       if length(y_l)>3000
           y=y_l(1:3000);
       else
           y=y_l;
       end
       if length(y)<700
           tP=0;
           tS=0;
           event_i.onda_P=tP;
           event_i.onda_S=tS;
           
           ondaP_(i)=nan;
           event_i.snr=  0;
           event_i.frec=0;
           event_i.amp=max(abs(yf));
          
       else
           iP=ondaP(y);
           iS=ondaS(y);
           if iS<=iP
               iS2=ondaS(y(iP:end));
               iS=iS2+iP;
           end
           if iP>0
           tP=event_i.time(iP);
           else
               tP=0;
           end
           if iS>0
           tS=event_i.time(iS);
           else
               tS=0;
           end
           event_i.onda_P=tP;
           event_i.onda_S=tS;
           ondaP_(i)=tP;           
           event_i.snr=10*log10(abs(mean(y(iP+50:end-100).^2)-mean(y(101:iP-100).^2))/mean(y(101:iP-100).^2));
           event_i.frec=frec_fun(yf);
           event_i.amp=max(abs(yf));
       end
      
   end
   event_i.volc=table1.volcan{i};
   %   event_i.volc=' ';
   event_i.code=table1.cod_event{i};
   %   event_i.code=' ';
   event_i.crdt=table1.created_at(i);
   event_i.pk=table1.cod_event_in(i);
   event_i.coda=table1.fin(i);
   event_i.comp=char(table1.componente(i));
   event_i.label=char(table1.label_event(i));
   event_i.inicio=(table1.inicio(i));
   eventoSolito(i)=event_i;
   try
       delete(['sacs/' sac_name '.SAC']);
   catch me
       disp(['No fue posible borrar el archivo ' sac_name '.SAC'])
   end
end
fi=i;
if sum(hayTrazas)==0
   error('Problema con trazas')
end
%% Reconocer macro-evento

clear eventoSolito_sorted
th=datenum(0,0,0,0,0,macro_sec); %4 segundos
[ondaP_sorted,i_sorted]=sort(ondaP_);
filt_nan=i_sorted(sum(ondaP_==0)+1:sum(~isnan(ondaP_)));
eventoSolito_sorted(:) = eventoSolito(filt_nan);
ondaP_sorted2(:) = ondaP_(filt_nan);
clear ondaP_sorted
ondaP_sorted=ondaP_sorted2;
i_estacion=nan(length(estacion_),1);
k=0;
i=1;
while i<=length(eventoSolito_sorted)
   t_in=ondaP_sorted(i);
   if t_in>0
   t_th=t_in+th;
   %en_estacion=zeros(3,1);
  
   k=k+1;
   while  ondaP_sorted(i)<=t_th
       macro(i)=k;
       t_macro(i)=t_in;
      % disp(k)
      % disp(datetime(t_in, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'))
      % [~,idx]=ismember(estaciones,estacion_(i_sorted(i)));
      % [~,i_estacion(i)]=max(idx);
       %en_estacion(i_estacion(i))=1;
       i=i+1;
       if i>sum(~isnan(ondaP_sorted))
           break;
       end
       %{
       if sum(en_estacion>=3) %Condición repetir estación
           break;
       end
       %}
   end
   else
       i=i+1;
   end
  
end
%{
figure('menubar','none')
rgb=rand(macro(end),3)./2+.5;
yyyy=etime(datevec(ondaP_sorted(end)),datevec(ondaP_sorted(1)))*[0 1 1 0];
hold on
for asd=1:length(macro)
   c_c=rgb(macro(asd),:);
   yytick(asd)=etime(datevec(ondaP_sorted(asd)),datevec(ondaP_sorted(1)));
   fill(asd+[.5 .5 -.5 -.5],yyyy,c_c,'LineStyle',"none")
end
plot(yytick,'k*')
grid minor;
ylabel('seg')
%}
%% Subir a la BD
t_macro2=t_macro;
macro2=macro;
clear t_macro macro
filt_time=(t_macro2>= r_in & t_macro2<= r_fn);
datos=eventoSolito_sorted(filt_time);
t_macro=t_macro2(filt_time);
macro=macro2(filt_time);
% datos=eventoSolito_sorted(t_macro2>= r_in & t_macro2<= r_fn);
% t_macro=t_macro2(t_macro2>= r_in & t_macro2<= r_fn);
% macro=macro2(t_macro2>= r_in & t_macro2<= r_fn);
%{
disp(['Tamaño t_macro2 es ' length(t_macro2)])
disp(['Tamaño t_macro es ' length(t_macro)])
disp(['Tamaño macro2 es ' length(macro2)])
disp(['Tamaño macro es ' length(macro)])
disp(['Tamaño datos es ' length(datos)])
%}
%%{
conn= MysqlConn(host,user,pass,db);
lastMacro=0;
for iEv=1:length(datos)
   PK=datos(iEv).pk;
   ID_Volcan=datos(iEv).volc;
   %ID_Volcan='xxx';
   Est=datos(iEv).esta;
   Componente=datos(iEv).comp;
   macro_event=datestr(t_macro(iEv),'yyyymmdd_HHMMSS.FFF');
   code_event=(datos(iEv).code);
   % code_event='0';
  
   ID_tecnica=1;
   Fecha_Pick=datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
   % Fecha_upd={datestr(now,'yyyy-mm-dd HH:MM:SS.FFF ')};
   autor='4Testing2';
   T_P= datestr(datos(iEv).onda_P,'yyyy-mm-dd HH:MM:SS.FFF');
   T_P(11)='T';
   T_P(24)='Z';
   T_P_c={T_P};
   T_S= datestr(datos(iEv).onda_S,'yyyy-mm-dd HH:MM:SS.FFF');
   T_S(11)='T';
   T_S(24)='Z';
   T_S_c={T_S};
   C_P=0;
   C_S=0;
   C_coda=0;
   INICIO=datestr(datos(iEv).inicio,'yyyy-mm-dd HH:MM:SS');
   %INICIO=(datos(iEv).inicio);
   SNR=(datos(iEv).snr);
   polar='nn';
   Fecha_cr= datestr(datos(iEv).crdt,'yyyy-mm-dd HH:MM:SS');
   %Fecha_cr= 'yyyy-mm-dd HH:MM:SS ';
  
   %Fecha_cr(10)='T';
   %Fecha_cr(20)='Z';
   descrip='Sin comentarios';
   Label_event=(datos(iEv).label);
   Amplitud=(datos(iEv).amp);
   coda=datestr(datos(iEv).coda,'yyyy-mm-dd HH:MM:SS');
   v_aux=1:length(macro);
   v_aux2=v_aux(macro==macro(iEv));
   coda2=datestr(datos(v_aux2(end)).coda,'yyyy-mm-dd HH:MM:SS');
  
   frecuencia=(datos(iEv).frec);
  
   stringAux=['''' code_event ''',' ...
       num2str(PK) ',' ...
       '''' macro_event ''',' ...
       '''' T_P ''',' ...
       '''' T_S ''',' ...
       '''' coda ''',' ...
       num2str(C_P) ',' ...
       num2str(C_S) ',' ...
       num2str(C_coda) ','...
       '''' INICIO ''',' ...
       '''' polar ''',' ...
       num2str(frecuencia) ','...
       num2str(Amplitud) ',' ...
       '''' autor ''',' ...
       '''' Label_event ''',' ...
       '''' descrip ''',' ...
       '''' Componente ''',' ...
       num2str(SNR) ',' ...
       num2str(ID_tecnica) ',' ...
       '''' Fecha_Pick '''' ...
       ];
  
  
   stringAux_me=['''' macro_event '''' ',' ...
       ID_Volcan ',' ...
       '''XX'',' ...
       '''' INICIO ''',' ...
       '''' coda2 '''' ',' ...
       num2str(0) ','...
       num2str(0) ...
       ];
  
   query_me=['INSERT INTO ufro_ovdas_v1.evento_macro (evento_macro_id,volcan_id,clasificacion,inicio,fin,probabilidad,confiabilidad) VALUES (' stringAux_me  ');'];
   query_p=['INSERT INTO ufro_ovdas_v1.avistamiento_registro (cod_event,cod_event_in,evento_macro_id,t_p,t_s,coda,c_p,c_s,c_coda,inicio,polar,frecuencia,amplitud,autor,label_event,descripcion,componente,snr,tecnica_id,fecha_pick) VALUES (' stringAux ');'];
   %%{
   if lastMacro<macro(iEv)
       curs3=exec(conn,query_me);
       if(isfield(curs3,'Message'))
           error(curs3.Message)
       end
       curs3  = fetch(curs3);
       lastMacro=macro(iEv);
   end
   curs4=exec(conn,query_p);
   if(isfield(curs4,'Message'))
       error(curs4.Message)
   end
   curs4  = fetch(curs4);
  
end
close(conn)
%}
  
%%
%%{
fileID = fopen('comentarios.txt','w');
fprintf(fileID,'Rutina finalizada a las %s \n',datestr(now));
fprintf(fileID,'%g avistamientos y %g macro-eventos subidos.\n',length(datos),macro(end));
if trazas_vacias>0
fprintf(fileID,'%g eventos con trazas vacías.\n',trazas_vacias);
end
fclose(fileID);
%}
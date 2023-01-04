def show_columns(tabla):
	fbx = conector()
	mycursor = fbx.cursor()
	sqlquery="show columns from "+tabla
	mycursor.execute(sqlquery)
	myresult = mycursor.fetchall()
	print(" -- Mostrando las columnas de la tabla "+tabla+" --\n")
	print('+----------------------+----------------------+------+------+----------------------+--------------------------------+')
	print('| Field                | Type                 | Null | Key  | Default              | Extra                          |')
	print('+----------------------+----------------------+------+------+----------------------+--------------------------------+')
	for x in myresult:
		print('| '+x[0].ljust(20, ' ')+' | '+x[1].ljust(20, ' ')+' | '+x[2].ljust(4, ' ')+' | '+x[3].ljust(4, ' ')+' | '+str(x[4]).ljust(20,' ')+' | '+x[5].ljust(30, ' ')+' | ')
	print('+----------------------+----------------------+------+------+----------------------+--------------------------------+\n')
	mycursor.close()
	fbx.close()
	return myresult

def show_tables():
	salida=[]
	fbx = conector()
	mycursor = fbx.cursor()
	sqlquery="show tables"
	mycursor.execute(sqlquery)
	myresult = mycursor.fetchall()
	print(" -- Mostrando las tablas en la base de datos  --\n")
	print('+------------------------+----------+')
	print('| Tabla                  | Cantidad |')
	print('+------------------------+----------+')
	for tabla in myresult:
		sqlquery="select count(*) from "+tabla[0]
		mycursor.execute(sqlquery)
		cantidad = mycursor.fetchall()
		print("| "+tabla[0].ljust(22,' ')+" | "+str(cantidad[0][0]).rjust(8," ")+" |")
		salida.append([tabla[0],cantidad[0][0]])
	print('+------------------------+----------+\n')
	mycursor.close()
	fbx.close()
	return salida

def query(sqlquery,visualizar="si"):
	## Establecer una opcion sobre si visualizar por consola el resultado o no
	fbx = conector()
	mycursor = fbx.cursor()
	mycursor.execute(sqlquery)
	myresult = mycursor.fetchall()
	if visualizar=="si":
		print("Mostrando la consulta:")
		print(' "'+sqlquery+'"')
		for registro in myresult:
			print(registro)
		print("\nPara un total de: ",end="")
		print(len(myresult),end="")
		print(" registros")
	mycursor.close()
	fbx.close()
	return myresult

def query_all(tabla):
	fbx = conector()
	mycursor = fbx.cursor()
	sqlquery="select * from "+tabla
	mycursor.execute(sqlquery)
	myresult = mycursor.fetchall()

	print("Mostrando la consulta:")
	print(' "'+sqlquery+'"\n')
	for registro in myresult:
		print(registro)

	mycursor.close()
	fbx.close()

def ejecutar(sql, val):
	fbx = conector()
	mycursor = fbx.cursor()
	mycursor.execute(sql, val)
	fbx.commit()
	print(mycursor.rowcount, "record inserted.")
	fbx.close()

def conector():
	import mysql.connector
	import configparser
	########################################################################
	## Inicializaciﾃｳn configuraciﾃｳn
	config = configparser.ConfigParser()
	config.read('C:/Users/diego/Desktop/ovdas pago informatico/newPrecote/conf2.conf')
	##############################################
	fbx = mysql.connector.connect(
		host=config['Database']['ip'],
		user=config['Database']['user'],
		password=config['Database']['password'],
		database=config['Database']['db'],
		connection_timeout=5
		)
	return fbx


function conn= MysqlConn(host, user, pass, db)

    %=======================
  
    
    jdbcString = sprintf('jdbc:mysql://%s/%s', host, db);
    jdbcDriver = 'com.mysql.jdbc.Driver';
    conn = database(db, user , pass, jdbcDriver, jdbcString);
    
end
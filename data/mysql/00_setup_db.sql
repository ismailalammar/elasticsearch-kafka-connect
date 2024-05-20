CREATE USER 'username'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
CREATE USER 'replicator'@'%' IDENTIFIED BY 'replpass';

GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO 'username';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replicator';

create database demo;

GRANT ALL PRIVILEGES ON demo.* TO 'username'@'%';

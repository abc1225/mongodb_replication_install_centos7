#!/bin/bash
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.0.2.tgz
tar -zxvf mongodb-linux-x86_64-rhel70-4.0.2.tgz
cp mongodb-linux-x86_64-rhel70-4.0.2/bin/* /usr/bin

cp config/* /etc/
chmod 777 /etc/mongod*

cp init.d/* /etc/init.d/
chmod 777 /etc/init.d/mongod*

chkconfig mongod on
chkconfig mongod_27018 on
chkconfig mongod_27019 on

mkdir -p /var/lib/mongo
chmod -R 777 /var/lib/mongo
mkdir -p /var/run/mongodb
chmod -R 777 /var/run/mongodb
mkdir -p /var/log/mongodb
chmod -R 777 /var/log/mongodb

mkdir -p /var/lib/mongo_27018
chmod -R 777 /var/lib/mongo_27018
mkdir -p /var/run/mongodb_27018
chmod -R 777 /var/run/mongodb_27018
mkdir -p /var/log/mongodb_27018
chmod -R 777 /var/log/mongodb_27018

mkdir -p /var/lib/mongo_27019
chmod -R 777 /var/lib/mongo_27019
mkdir -p /var/run/mongodb_27019
chmod -R 777 /var/run/mongodb_27019
mkdir -p /var/log/mongodb_27019
chmod -R 777 /var/log/mongodb_27019

# README #

# 安装 #

	一、 执行install.sh 将安装好三个 mongodDB, 即执行以下a和b的步骤，启动命令：
		
	service mongod start
	service mongod_27018 start
	service mongod_27019 start	

	a. 将mongo下载后, 拷贝至 /usr/bin/ 目录下
	b. 将init.d下的启动脚本放置 /etc/init.d 下 config下的脚本放置 /etc/下

	二、 修改三个配置文件mongod*.conf绑定的IP地址 (注意： 连接公网的服务器，千万不要把公网地址绑定上去!!!)

	三、 配置复制集, 并设置主库优先级 

# MongoDB复制集的概述 #

	复制集是额外的数据副本，是跨多个服务器同步数据的过程，复制集提供了冗余并增加了数据可用性，通过复制集可以对硬件故障和中断的服务进行恢复。

# 复制集工作原理 #

	MongoDB的复制集至少需要两个节点。其中一个是主节点（primary），负责处理客户端的请求，其余都是从节点（Secondary）,负责复制主节点上的数据。
	MongoDB各个节点常见的搭配方式为：一主一从或一主多从。主节点记录其上的所有操作到oplog中，从节点定期轮询主节点获取这些操作，然后对自己的数副本执行这些操作，从而保证从节点的数据与主节点一致。
	复制集的特点

	N个节点的群集
	任何节点可作为主节点
	所有写入操作都在主节点上
	自动故障转移
	自动恢复

# 启动 #

	注意：
	27018和27019副本上的启动用户为 root 用户 否则有权限问题，启动不了

	service mongod start
	service mongod_27018 start
	service mongod_27019 start

# 复制集配置 #

	在主节点上执行以下命令	

	>mongo 127.0.0.1:27017
	> rs.status()    			//查看复制集
	> rs.initiate(cfg)   			//初始化配置时保证从节点没有数据// 
	kgcrs:SECONDARY> rs.status()   		//启动复制集后，再次通过rs.status()命令查看复制集的完整状态信息   health为1代表健康，0代表宕机。state为1代表主节点，为2代表从节点。  在复制集初始化配置时要保证从节点上没有数据

# 添加从节点 #
	
	> rs.add('127.0.0.1:27018')
	> rs.add('127.0.0.1:27019')

# MongoDB复制集切换 #

	MongoDB复制集可以实现群集的高可用，当其中主节点出现故障时会自动切换到其他节点。也可手动进行复制集的主从切换。

	1.故障自动转移切换
	kill一个主节点，查看复制集状态，主节点已转移
	rs.status()

	2.手动进行主从切换

	kgcrs:PRIMARY> rs.freeze(30)      		//暂停30s不参与选举
	kgcrs:PRIMARY> rs.stepDown(60,30)  		//交出主节点位置，维持从节点状态不少于60秒，等待30秒使主节点和从节点日志同步
	kgcrs:SECONDARY>    				//交出主节点后立马变成从节点， 等待30后，主节点由其他从节点产生//
	kgcrs:SECONDARY> rs.status()


# MongoDB复制集的选举原理 #

	节点类型分为标准节点（host）、被动节点（passive）和仲裁节点（arbiter）。

	只有标准节点可能被选举为活跃（primary）节点，有选举权。被动节点有完整副本，不可能成为活跃节点，有选举权。仲裁节点不复制数据，不可能成为活跃节点，只有选举权。
	标准节点与被动节点的区别：priority值高者是标准节点，低者为被动节点。
	选举规则是票数高者获胜，priority是优先权为0~1000的值，相当于额外增加0~1000的票数。选举结果：票数高者获胜；若票数相同，数据新者获胜。


# MongoDB复制集管理 #

	1.配置允许在从节点读取数据

	默认MongoDB复制集的从节点不能读取数据，可以使用rs.slaveOk()命令允许能够在从节点读取数据。

	2.查看复制状态信息

	可以使用 rs.printReplicationInfo()和rs.printSlaveReplicationInfo()命令查看复制集状态。

# 控制主库的优先级 #
	
	功能； 当主库暂时挂掉后, 重启之后, 主库能自动切换回来

	rs0:PRIMARY> config = rs.conf()
	{
		"_id" : "rs0",
		"version" : 4,
		"protocolVersion" : NumberLong(1),
		"writeConcernMajorityJournalDefault" : true,
		"members" : [
			{
				"_id" : 0,
				"host" : "127.0.0.1:27017",
				"arbiterOnly" : false,
				"buildIndexes" : true,
				"hidden" : false,
				"priority" : 2,
				"tags" : {
				
				},
				"slaveDelay" : NumberLong(0),
				"votes" : 1
			},
			{
				"_id" : 1,
				"host" : "127.0.0.1:27018",
				"arbiterOnly" : false,
				"buildIndexes" : true,
				"hidden" : false,
				"priority" : 1,
				"tags" : {
				
				},
				"slaveDelay" : NumberLong(0),
				"votes" : 1
			},
			{
				"_id" : 2,
				"host" : "127.0.0.1:27019",
				"arbiterOnly" : false,
				"buildIndexes" : true,
				"hidden" : false,
				"priority" : 1,
				"tags" : {
				
				},
				"slaveDelay" : NumberLong(0),
				"votes" : 1
			}
		],
		"settings" : {
			"chainingAllowed" : true,
			"heartbeatIntervalMillis" : 2000,
			"heartbeatTimeoutSecs" : 10,
			"electionTimeoutMillis" : 10000,
			"catchUpTimeoutMillis" : -1,
			"catchUpTakeoverDelayMillis" : 30000,
			"getLastErrorModes" : {
			
			},
			"getLastErrorDefaults" : {
				"w" : 1,
				"wtimeout" : 0
			},
			"replicaSetId" : ObjectId("5b62fee8e80fd0cc87921f02")
		}
	}

	rs0:PRIMARY> config.members[0].priority = 3
	3

	rs0:PRIMARY> rs.reconfig(config)
	{
		"ok" : 1,
		"operationTime" : Timestamp(1535076541, 1),
		"$clusterTime" : {
			"clusterTime" : Timestamp(1535076541, 1),
			"signature" : {
				"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
				"keyId" : NumberLong(0)
			}
		}
	}





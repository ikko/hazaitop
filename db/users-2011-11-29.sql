-- MySQL dump 10.13  Distrib 5.1.49, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: kwiw_new
-- ------------------------------------------------------
-- Server version	5.1.49-3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `crypted_password` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `salt` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `administrator` tinyint(1) DEFAULT '0',
  `editor` tinyint(1) DEFAULT '0',
  `supervisor` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'invited',
  `key_timestamp` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_users_on_state` (`state`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'7e54edfb5107df54e69c0f7b56558860ec232216','ac2b64c26d017e3edfd5a3bd1e77d8b5579f4290','300272d30f12564b5409b27b85b46f07cf612e88','2011-11-09 20:50:50','Béky Miklós','miklos.beky@gmail.com',1,0,0,'2011-01-04 12:03:25','2011-10-26 19:50:50','active',NULL),(2,'72a0cc3a310d959d26585d24993fe02e23944aa7','c4750a56b53399230ac846c4889406466c5314f8',NULL,NULL,'Komzák Nándor','nandor.komzak@gmail.com',1,0,0,'2011-01-04 12:03:25','2011-01-10 11:21:19','active',NULL),(3,'034616f8cc7ff96b66361c68a67820ae4064658d','35915b1aa17266f946243e64000c23ee4e2608da','9ca9801873e86ef48178e2277140f686a4e83d8d','2011-12-02 10:23:56','Léderer Sándor','lederer@k-monitor.hu',1,1,1,'2011-01-04 12:03:25','2011-11-18 10:23:56','active',NULL),(4,'d7284759e1fed045f9d42a76e6b89b5ae4f057fc','0bf447f22ada772ff1c308944a7dd1e2e9ef2000',NULL,NULL,'Keserű Júlia','keseru.julia@k-monitor.hu',0,1,1,'2011-01-04 12:03:26','2011-01-10 11:21:19','active',NULL),(5,NULL,NULL,NULL,NULL,'Nagy Boglárka','eip.nagy.boglarka@gmail.com',0,1,1,'2011-01-10 11:25:15','2011-01-10 11:37:45','invited','2011-01-10 11:25:15'),(6,NULL,NULL,NULL,NULL,'nemistud@gmail.com','nemistud@gmail.com',0,1,1,'2011-01-10 11:25:59','2011-01-10 11:25:59','invited','2011-01-10 11:25:59'),(7,'d42f3d9d799563daee73c44165dda3db07900e25','4e0093488ac312add1ee506d02fd6d980084b817','3846c335b716fa718ea2cbbc64551f5207d4eb80','2011-04-25 16:30:23','zalchi@gmail.com','zalan9@gmail.com',0,1,1,'2011-01-10 11:26:24','2011-04-11 16:30:23','active','2011-01-10 11:26:24'),(8,NULL,NULL,NULL,NULL,'Takács Flóra','floratakacs@gmail.com',0,1,1,'2011-01-10 11:26:51','2011-01-10 11:26:51','invited','2011-01-10 11:26:50'),(9,NULL,NULL,NULL,NULL,'ejulcsi@gmail.com','ejulcsi@gmail.com',0,1,1,'2011-01-10 11:27:11','2011-01-10 11:27:11','invited','2011-01-10 11:27:11'),(10,'e57be6641a8fcde632fdc2996a79111110d1986e','0cfbf3132ac8334a0ff7de0c910585260ae75360',NULL,NULL,'atajti@gmail.com','atajti@gmail.com',0,1,1,'2011-01-10 11:32:29','2011-01-11 12:06:26','active','2011-01-10 11:32:29'),(11,NULL,NULL,NULL,NULL,'Rado Márti','marti.rado@gmail.com',0,1,1,'2011-01-10 11:33:10','2011-01-10 11:33:10','invited','2011-01-10 11:33:10'),(12,'fd93e94da5904494c5261144719a0e28c9232b33','dfd657a2ff1ffd0cf11b42039132a4995f39b923','0870e40818be7af09441fcf627d1e190df822baf','2011-02-20 23:08:29','virag08@gmail.com','virag08@gmail.com',0,1,1,'2011-01-10 11:33:38','2011-11-10 09:55:33','active','2011-01-10 11:33:38'),(14,'7ddb097371fe9636fd7bb45b9da38a43ead92f28','2c8dbe381eadb0c0a1260ac06951bf80e11c01ea',NULL,NULL,'Dénes Balázs','dnsbali@tasz.hu',1,1,1,'2011-01-10 15:03:25','2011-01-10 15:06:21','active','2011-01-10 15:03:25'),(15,NULL,NULL,NULL,NULL,'Földes Ádám','adam.foldes@transparency.hu',0,1,1,'2011-01-10 15:04:26','2011-01-10 15:04:26','invited','2011-01-10 15:04:25'),(16,'6a26113f5ae7566621bcd2b77811800197f53cd5','fa9d8ebf5233828322fe5a2adf90a64cdedbb51b',NULL,NULL,'Alexa Noémi','noemi.alexa@transparency.hu',0,1,0,'2011-01-10 15:05:29','2011-01-17 09:57:21','active','2011-01-10 15:05:29'),(17,'6b527146d8b9f18c00f205e130d5288e8ef8bde3','a929fce111ea73df2ea43ce869dc2c984ab63e89',NULL,NULL,'Hüttl Tivadar','huttl@tasz.hu',0,1,0,'2011-01-10 15:06:02','2011-01-10 15:17:21','active','2011-01-10 15:06:02'),(18,'0b5a4092c595410d7032a8127f67612d168bb3fc','5397bb5a546558177eed00cca586879f66ada3b6','625179dae0182e3066a6551846f2111352e42f8e','2011-04-21 10:03:45','Komoróczki Tünde','t.komoroczki@k-monitor.hu',0,1,1,'2011-01-17 12:50:36','2011-04-07 10:12:43','active','2011-01-17 12:50:36'),(19,'0fa8385bcb306bafba700c966c8c758e3ccff9a2','109fec41eeee31da755cab15f3aff34d621a0baf',NULL,NULL,'Madarász Csaba','madarasz.csaba@gmail.com',1,1,1,'2011-01-18 00:46:47','2011-01-18 01:14:38','active','2011-01-18 00:46:47'),(20,'48561e94af8065f039a0d7cbaf6095ff5928950a','2b3fb8b93b2deae03960b2dd2b89fc2115778d64','506a97da029575af648f7affa88b16a9afd542ce','2011-09-22 13:35:26','Kondorosi Kinga','kondorosi.kinga@gmail.com',0,1,1,'2011-01-27 10:31:27','2011-09-08 13:35:26','active','2011-01-27 10:31:27'),(21,NULL,NULL,NULL,NULL,'Stephen King','sking@omidyar.com',0,1,1,'2011-02-02 08:34:54','2011-02-02 08:34:54','invited','2011-02-02 08:34:54'),(23,NULL,NULL,NULL,NULL,'Juhasz Istvan','arcomsem@gmail.com',0,1,1,'2011-02-17 09:37:46','2011-02-17 09:37:46','invited','2011-02-17 09:37:46'),(24,'e695013c10507f97a69d87dafb78ddc9de962c56','b346a1288c1a4bef91c88f20208aba36e31d6142','55e03d872a15f538fc05ec1cb7b166d0bc2fb04c','2011-03-21 10:09:06','Juhász István','istvan.juhasz.bp@gmail.com',0,1,0,'2011-02-17 14:15:58','2011-03-07 10:09:06','active',NULL),(25,'ebfc1d36a75fbc1e6a844d0a0f7cb7d97640b1e1','c9931236451fea0fba4c4a45f2dd37a7e4e1a414','0a9c6eb532d15361dca036a808a78d0dfd9239e9','2011-09-06 08:38:15','adam','ferik.adam@freemail.hu',0,1,0,'2011-07-08 09:19:23','2011-08-23 08:38:15','active','2011-07-08 09:19:23'),(26,NULL,NULL,NULL,NULL,'léderer sanyi','lederersandor@gmail.com',0,1,0,'2011-07-08 12:45:26','2011-07-08 12:45:26','invited','2011-07-08 12:45:26'),(27,'6830422021915985878d29a785315209a26c0c9d','2c79c08db755bcd79249b55637bc512090aaa279','4970dd6d9cffffaff38d90264de8d3a78b7f0ede','2011-07-22 18:19:06','Hack Sára','sara.hack@hotmail.com',0,1,0,'2011-07-08 14:07:17','2011-07-08 18:19:06','active',NULL),(28,'cb2378a8b5cdacdfb74ec406e65e57e086808198','a13b5c84393a01688c6c1c2ddc77bdc2d9adb74b','3bee11d5a17ce5ee21a0f045098f8538a28bcc76','2011-08-03 19:22:11','Salgó Ella','ellasalgo@gmail.com',0,1,0,'2011-07-08 14:08:11','2011-07-20 19:22:11','active',NULL),(29,'eac229734e10bb2136ddc65cb43c88e2b0432231','bd50dd948bd8d20bade9ccaee4a8b7a98f2f65fd',NULL,NULL,'Takács Péter','eltetaki@vipmail.hu',0,1,0,'2011-07-08 14:09:02','2011-07-08 14:09:56','active',NULL),(30,'7fef13caeb693e95741b7cc90e147836453cb24e','33a0bb33f0c6301e61e4e10e020d7e6e2df5212e','ec1af536dcff7907abc1423fa4af99b73bb4f065','2011-08-11 15:19:18','Alfa','lordgoder@hotmail.com',0,1,0,'2011-07-18 13:32:59','2011-07-28 15:19:18','active','2011-07-18 13:32:58'),(31,'d86bec234cd2670bca7069ee6d574da72b48e31a','0d966838763c0b09deb7c6d43015108ee5e79a22',NULL,NULL,'Beta','beta@ifindeye.hu',0,0,0,'2011-07-30 12:54:30','2011-07-30 12:54:55','active',NULL),(32,NULL,NULL,NULL,NULL,'Alpha','abeta@ifindeye.hu',0,0,0,'2011-07-30 12:58:09','2011-07-30 12:58:09','invited',NULL),(33,'ac39e3d7cdfa1cd4bbfcae3da4aa26111dec978e','8018c96882bd650cee8df141e7ead65d98e90b6b',NULL,NULL,'Sebestyén Ági','aagnes.sebestyen@gmail.com',0,1,0,'2011-08-02 07:49:04','2011-08-02 07:50:14','active',NULL),(34,'e05b3519485093c7a6df5354dca524c8cc65098a','72241092e55ed0e3d609107c5bbfa090dff27f02','a4229533e99264a117113cc96e260727ab1228e5','2011-12-12 11:16:49','vincze orsi','vinczeorsi@gmail.com',0,1,0,'2011-09-06 11:19:44','2011-11-28 11:16:49','active',NULL),(35,'188e769d77eaeb8b24d3150864384a8063868464','3fe1f91d7756312c4eec58bc30b6aa60bfd8872f',NULL,NULL,'Erdei Miklós','erdei.miklos@yahoo.com',0,1,0,'2011-10-20 09:59:15','2011-10-25 07:27:26','active','2011-10-20 09:59:15'),(36,'a97184e4e56610c2d800a04ccf98dd6983f3cbe1','6bb10bb10fdc7048ba153da0820badba7b08dc73',NULL,NULL,'Molnar Attila','attamolnar@gmail.com',0,1,0,'2011-10-20 11:38:30','2011-11-24 04:23:34','active','2011-10-20 11:38:30'),(37,'67e46bd839837578a7696ae0a9329bb439b1aeb0','adb4a4cbf64bf94e503461f01151f2b0fe0cce5f',NULL,NULL,'Megyeri Kata','kata.megyeri@gmail.com',0,1,0,'2011-10-23 11:04:47','2011-11-03 16:59:48','active',NULL),(38,'81c2c479d97fec76caf62105751e777fbc0cb299','26cb6ff86da5d512c64c16a61a4d56eb2f4fc686','0f7bccc84beb77c18cf8278d2fa3ed9acaff577c','2011-11-10 14:14:29','Zsámboki Kati','zsamboki.kati@gmail.com',0,1,0,'2011-10-23 11:07:19','2011-10-27 13:14:29','active',NULL),(39,'52a278f4944c6cec7c8537099e4c8d6d3d86af92','bcf6fc8eb7f69f0885141c0302fb6bcefec3408d',NULL,NULL,'Haluska György','gyorgy.haluska@linuxhungary.hu',1,1,1,'2011-10-25 19:45:42','2011-10-25 21:26:12','active','2011-10-25 19:45:42'),(40,'454cc7159ffe1e66071e481f153f2ae9cfd878d4','acff94579e39d412e88e4c266450e0b503930eda','8371f8bd88a89873dcef416c07fb0dcc7e93d286','2011-12-07 11:41:24','Kiss Benjamin','kissbenjamin@gmail.com',0,1,0,'2011-11-04 14:05:04','2011-11-23 11:41:24','active','2011-11-04 14:05:04'),(41,'ca717fa70610bb1968053d6ba7ebb2a55df96487','e6f64e711756ead8ca7708e6174b04412094c567','71bae95ba5e3614955043a03d4183ee3b8054e23','2011-12-13 08:25:12','Linka Máté','linka.mate@gmail.com',0,1,0,'2011-11-08 15:08:55','2011-11-29 08:25:12','active','2011-11-08 15:08:55'),(42,'9a3febcccce700d6ab34db6d172de903e65f62f7','8b15531c7ef62c180871667f49efd3415057237e','eb42379ac9645cd458f2df9b53937948201a91a9','2011-12-01 16:49:46','Bozsó Ildikó','bozsoildiko91@gmail.com',0,1,0,'2011-11-08 15:09:49','2011-11-17 16:49:46','active','2011-11-08 15:09:49'),(43,NULL,NULL,NULL,NULL,'Vogl Miklós','miklosvogl@gmail.com',0,1,0,'2011-11-08 15:10:17','2011-11-09 14:46:31','active','2011-11-08 15:10:17');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-11-29 13:40:59

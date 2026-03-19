-- MySQL dump 10.13  Distrib 8.0.2-dmr, for Win64 (x86_64)
--
-- Host: localhost    Database: bus_reservation
-- ------------------------------------------------------
-- Server version	8.0.2-dmr-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `amenities`
--

DROP TABLE IF EXISTS `amenities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `amenities` (
  `amenity_id` int(11) NOT NULL AUTO_INCREMENT,
  `amenity_name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`amenity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `amenities`
--

LOCK TABLES `amenities` WRITE;
/*!40000 ALTER TABLE `amenities` DISABLE KEYS */;
INSERT INTO `amenities` VALUES (1,'WiFi'),(2,'AC'),(3,'Charging Point'),(4,'Blanket');
/*!40000 ALTER TABLE `amenities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL AUTO_INCREMENT,
  `bus_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `pnr` varchar(20) DEFAULT NULL,
  `passenger_name` varchar(100) DEFAULT NULL,
  `passenger_email` varchar(100) DEFAULT NULL,
  `passenger_mobile` varchar(15) DEFAULT NULL,
  `passenger_age` int(11) DEFAULT NULL,
  `seat_numbers` varchar(100) DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `payment_status` enum('Pending','Success','Failed') DEFAULT 'Pending',
  `status` enum('Confirmed','Cancelled') DEFAULT 'Confirmed',
  `razorpay_order_id` varchar(100) DEFAULT NULL,
  `razorpay_payment_id` varchar(100) DEFAULT NULL,
  `booking_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`booking_id`),
  UNIQUE KEY `pnr` (`pnr`),
  KEY `bus_id` (`bus_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`bus_id`),
  CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bus_amenities`
--

DROP TABLE IF EXISTS `bus_amenities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `bus_amenities` (
  `bus_id` int(11) NOT NULL,
  `amenity_id` int(11) NOT NULL,
  PRIMARY KEY (`bus_id`,`amenity_id`),
  KEY `amenity_id` (`amenity_id`),
  CONSTRAINT `bus_amenities_ibfk_1` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`bus_id`),
  CONSTRAINT `bus_amenities_ibfk_2` FOREIGN KEY (`amenity_id`) REFERENCES `amenities` (`amenity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bus_amenities`
--

LOCK TABLES `bus_amenities` WRITE;
/*!40000 ALTER TABLE `bus_amenities` DISABLE KEYS */;
INSERT INTO `bus_amenities` VALUES (1,1),(3,1),(4,1),(6,1),(8,1),(10,1),(12,1),(13,1),(15,1),(16,1),(17,1),(19,1),(21,1),(23,1),(27,1),(30,1),(1,2),(3,2),(4,2),(5,2),(6,2),(8,2),(10,2),(12,2),(13,2),(15,2),(17,2),(19,2),(20,2),(21,2),(23,2),(27,2),(30,2),(1,3),(2,3),(3,3),(5,3),(7,3),(8,3),(9,3),(11,3),(12,3),(16,3),(19,3),(20,3),(27,3),(3,4),(10,4),(12,4),(23,4);
/*!40000 ALTER TABLE `bus_amenities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buses`
--

DROP TABLE IF EXISTS `buses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `buses` (
  `bus_id` int(11) NOT NULL AUTO_INCREMENT,
  `bus_name` varchar(100) DEFAULT NULL,
  `bus_type` varchar(50) DEFAULT NULL,
  `price_per_seat` int(11) DEFAULT NULL,
  `route_id` int(11) DEFAULT NULL,
  `operator_id` int(11) DEFAULT NULL,
  `departure_time` time DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `travel_date` datetime DEFAULT NULL,
  `rating` decimal(2,1) DEFAULT NULL,
  PRIMARY KEY (`bus_id`),
  KEY `route_id` (`route_id`),
  KEY `operator_id` (`operator_id`),
  CONSTRAINT `buses_ibfk_1` FOREIGN KEY (`route_id`) REFERENCES `routes` (`route_id`),
  CONSTRAINT `buses_ibfk_2` FOREIGN KEY (`operator_id`) REFERENCES `operators` (`operator_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buses`
--

LOCK TABLES `buses` WRITE;
/*!40000 ALTER TABLE `buses` DISABLE KEYS */;
INSERT INTO `buses` VALUES (1,'Shivneri Gold','AC Sleeper',550,1,1,'07:00:00','11:00:00','2026-03-20 12:00:00',4.5),(2,'Neeta Express','Non-AC Seater',350,1,2,'09:00:00','13:00:00','2026-03-20 12:00:00',4.1),(3,'Red Prime Luxury','AC Sleeper',650,1,3,'22:00:00','02:00:00','2026-03-21 12:00:00',4.8),(4,'Purple Metrolink 1','AC Sleeper',600,1,4,'23:00:00','03:00:00','2026-03-21 12:00:00',4.3),(5,'VRL Pune Special','AC Sleeper',700,1,5,'21:30:00','01:30:00','2026-03-22 12:00:00',4.2),(6,'Shivneri Silver','AC Sleeper',480,2,1,'10:00:00','14:00:00','2026-03-20 12:00:00',4.4),(7,'Neeta Connect','Non-AC Seater',320,2,2,'13:00:00','17:00:00','2026-03-20 12:00:00',4.0),(8,'Red Prime Nashik','AC Sleeper',520,2,3,'23:30:00','03:30:00','2026-03-21 12:00:00',4.6),(9,'Purple Metrolink 2','Non-AC Seater',310,2,4,'06:00:00','10:00:00','2026-03-18 12:00:00',3.9),(10,'VRL Nashik Express','AC Sleeper',580,2,5,'18:00:00','22:00:00','2026-03-19 12:00:00',4.4),(11,'MSRTC Hirkani Pune','Non-AC Seater',280,3,6,'05:30:00','10:30:00','2026-03-20 12:00:00',4.2),(12,'Khurana Sleeper','AC Sleeper',620,3,7,'22:15:00','03:15:00','2026-03-25 12:00:00',4.7),(13,'Shivneri Platinum','AC Sleeper',750,1,1,'08:00:00','12:00:00','2026-03-20 12:00:00',4.9),(14,'Neeta Nashik Star','Non-AC Seater',340,3,2,'14:00:00','19:00:00','2026-03-17 12:00:00',3.7),(15,'Red Prime Night King','AC Sleeper',680,3,3,'23:45:00','04:45:00','2026-03-21 12:00:00',4.5),(16,'National Highway King','AC Sleeper',610,2,8,'20:00:00','00:00:00','2026-03-17 12:00:00',4.3),(17,'Prasanna Pune Express','AC Seater',420,4,9,'06:30:00','10:30:00','2026-03-19 12:00:00',4.6),(18,'Khurana Seater','Non-AC Seater',290,4,7,'12:00:00','16:00:00','2026-03-14 12:00:00',3.8),(19,'National Connect','AC Sleeper',590,3,8,'21:00:00','02:00:00','2026-03-20 12:00:00',4.1),(20,'MSRTC Shivshahi','AC Seater',400,1,6,'15:00:00','19:00:00','2026-03-20 12:00:00',4.4),(21,'Saini Travels AC','AC Sleeper',640,5,10,'22:00:00','03:00:00','2026-03-21 12:00:00',4.3),(22,'Chintamani Express','Non-AC Seater',300,5,11,'07:30:00','12:30:00','2026-03-20 12:00:00',3.9),(23,'Shivneri Diamond','AC Sleeper',800,1,1,'06:00:00','10:00:00','2026-03-20 12:00:00',4.8),(24,'Neeta Night Queen','AC Sleeper',670,4,2,'23:30:00','03:30:00','2026-03-19 12:00:00',4.4),(25,'Red Prime Connect','AC Seater',450,2,3,'08:00:00','12:00:00','2026-03-20 12:00:00',4.2),(26,'Purple Morning Star','Non-AC Seater',330,1,4,'05:00:00','09:00:00','2026-03-19 12:00:00',4.0),(27,'VRL Superfast','AC Sleeper',720,3,5,'19:00:00','00:00:00','2026-03-20 12:00:00',4.5),(28,'Saini Nashik Special','AC Sleeper',550,2,10,'21:00:00','01:00:00','2026-03-21 12:00:00',4.1),(29,'Chintamani Pune Gold','AC Seater',430,3,11,'11:00:00','16:00:00','2026-03-20 12:00:00',4.3),(30,'MSRTC Ashvamedh','AC Seater',500,4,6,'09:00:00','13:00:00','2026-03-20 12:00:00',4.7);
/*!40000 ALTER TABLE `buses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operators`
--

DROP TABLE IF EXISTS `operators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `operators` (
  `operator_id` int(11) NOT NULL AUTO_INCREMENT,
  `operator_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`operator_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operators`
--

LOCK TABLES `operators` WRITE;
/*!40000 ALTER TABLE `operators` DISABLE KEYS */;
INSERT INTO `operators` VALUES (1,'Shivneri Private Luxury'),(2,'Neeta Travels'),(3,'Red Prime'),(4,'Purple Metrolink'),(5,'VRL Travels'),(6,'MSRTC Hirkani'),(7,'Khurana Travels'),(8,'National Travels'),(9,'Prasanna Purple'),(10,'Saini Travels'),(11,'Chintamani Travels');
/*!40000 ALTER TABLE `operators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `routes`
--

DROP TABLE IF EXISTS `routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `routes` (
  `route_id` int(11) NOT NULL AUTO_INCREMENT,
  `source` varchar(50) DEFAULT NULL,
  `destination` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`route_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
INSERT INTO `routes` VALUES (1,'pune','mumbai'),(2,'mumbai','nashik'),(3,'pune','nashik'),(4,'mumbai','pune'),(5,'nashik','pune');
/*!40000 ALTER TABLE `routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seats`
--

DROP TABLE IF EXISTS `seats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `seats` (
  `seat_id` int(11) NOT NULL AUTO_INCREMENT,
  `bus_id` int(11) DEFAULT NULL,
  `seat_number` varchar(10) DEFAULT NULL,
  `seat_type` enum('Sleeper','Seater') DEFAULT 'Sleeper',
  `is_booked` tinyint(1) DEFAULT '0',
  `reserved_for` enum('General','Female') DEFAULT 'General',
  `price_modifier` int(11) DEFAULT '0',
  PRIMARY KEY (`seat_id`),
  KEY `bus_id` (`bus_id`),
  CONSTRAINT `seats_ibfk_1` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`bus_id`)
) ENGINE=InnoDB AUTO_INCREMENT=767 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seats`
--

LOCK TABLES `seats` WRITE;
/*!40000 ALTER TABLE `seats` DISABLE KEYS */;
INSERT INTO `seats` VALUES (1,1,'L1','Sleeper',0,'General',0),(2,3,'L1','Sleeper',0,'General',0),(3,4,'L1','Sleeper',0,'General',0),(4,5,'L1','Sleeper',0,'General',0),(5,6,'L1','Sleeper',0,'General',0),(6,8,'L1','Sleeper',0,'General',0),(7,10,'L1','Sleeper',0,'General',0),(8,12,'L1','Sleeper',0,'General',0),(9,13,'L1','Sleeper',0,'General',0),(10,15,'L1','Sleeper',0,'General',0),(11,16,'L1','Sleeper',0,'General',0),(12,19,'L1','Sleeper',0,'General',0),(13,21,'L1','Sleeper',0,'General',0),(14,23,'L1','Sleeper',0,'General',0),(15,24,'L1','Sleeper',0,'General',0),(16,27,'L1','Sleeper',0,'General',0),(17,28,'L1','Sleeper',0,'General',0),(18,1,'L2','Sleeper',0,'Female',0),(19,3,'L2','Sleeper',0,'Female',0),(20,4,'L2','Sleeper',0,'Female',0),(21,5,'L2','Sleeper',0,'Female',0),(22,6,'L2','Sleeper',0,'Female',0),(23,8,'L2','Sleeper',0,'Female',0),(24,10,'L2','Sleeper',0,'Female',0),(25,12,'L2','Sleeper',0,'Female',0),(26,13,'L2','Sleeper',0,'Female',0),(27,15,'L2','Sleeper',0,'Female',0),(28,16,'L2','Sleeper',0,'Female',0),(29,19,'L2','Sleeper',0,'Female',0),(30,21,'L2','Sleeper',0,'Female',0),(31,23,'L2','Sleeper',0,'Female',0),(32,24,'L2','Sleeper',0,'Female',0),(33,27,'L2','Sleeper',0,'Female',0),(34,28,'L2','Sleeper',0,'Female',0),(35,1,'L3','Sleeper',0,'General',0),(36,3,'L3','Sleeper',0,'General',0),(37,4,'L3','Sleeper',1,'General',0),(38,5,'L3','Sleeper',0,'General',0),(39,6,'L3','Sleeper',1,'General',0),(40,8,'L3','Sleeper',1,'General',0),(41,10,'L3','Sleeper',1,'General',0),(42,12,'L3','Sleeper',1,'General',0),(43,13,'L3','Sleeper',0,'General',0),(44,15,'L3','Sleeper',0,'General',0),(45,16,'L3','Sleeper',1,'General',0),(46,19,'L3','Sleeper',0,'General',0),(47,21,'L3','Sleeper',0,'General',0),(48,23,'L3','Sleeper',0,'General',0),(49,24,'L3','Sleeper',1,'General',0),(50,27,'L3','Sleeper',0,'General',0),(51,28,'L3','Sleeper',1,'General',0),(52,1,'L4','Sleeper',0,'General',0),(53,3,'L4','Sleeper',0,'General',0),(54,4,'L4','Sleeper',0,'General',0),(55,5,'L4','Sleeper',0,'General',0),(56,6,'L4','Sleeper',0,'General',0),(57,8,'L4','Sleeper',0,'General',0),(58,10,'L4','Sleeper',0,'General',0),(59,12,'L4','Sleeper',0,'General',0),(60,13,'L4','Sleeper',0,'General',0),(61,15,'L4','Sleeper',0,'General',0),(62,16,'L4','Sleeper',0,'General',0),(63,19,'L4','Sleeper',0,'General',0),(64,21,'L4','Sleeper',0,'General',0),(65,23,'L4','Sleeper',0,'General',0),(66,24,'L4','Sleeper',0,'General',0),(67,27,'L4','Sleeper',0,'General',0),(68,28,'L4','Sleeper',0,'General',0),(69,1,'L5','Sleeper',0,'General',0),(70,3,'L5','Sleeper',0,'General',0),(71,4,'L5','Sleeper',0,'General',0),(72,5,'L5','Sleeper',0,'General',0),(73,6,'L5','Sleeper',0,'General',0),(74,8,'L5','Sleeper',0,'General',0),(75,10,'L5','Sleeper',0,'General',0),(76,12,'L5','Sleeper',0,'General',0),(77,13,'L5','Sleeper',0,'General',0),(78,15,'L5','Sleeper',0,'General',0),(79,16,'L5','Sleeper',0,'General',0),(80,19,'L5','Sleeper',0,'General',0),(81,21,'L5','Sleeper',0,'General',0),(82,23,'L5','Sleeper',0,'General',0),(83,24,'L5','Sleeper',0,'General',0),(84,27,'L5','Sleeper',0,'General',0),(85,28,'L5','Sleeper',0,'General',0),(86,1,'L6','Sleeper',0,'General',0),(87,3,'L6','Sleeper',0,'General',0),(88,4,'L6','Sleeper',0,'General',0),(89,5,'L6','Sleeper',0,'General',0),(90,6,'L6','Sleeper',0,'General',0),(91,8,'L6','Sleeper',0,'General',0),(92,10,'L6','Sleeper',0,'General',0),(93,12,'L6','Sleeper',0,'General',0),(94,13,'L6','Sleeper',0,'General',0),(95,15,'L6','Sleeper',0,'General',0),(96,16,'L6','Sleeper',0,'General',0),(97,19,'L6','Sleeper',0,'General',0),(98,21,'L6','Sleeper',0,'General',0),(99,23,'L6','Sleeper',0,'General',0),(100,24,'L6','Sleeper',0,'General',0),(101,27,'L6','Sleeper',0,'General',0),(102,28,'L6','Sleeper',0,'General',0),(103,1,'L7','Sleeper',0,'General',0),(104,3,'L7','Sleeper',0,'General',0),(105,4,'L7','Sleeper',0,'General',0),(106,5,'L7','Sleeper',0,'General',0),(107,6,'L7','Sleeper',0,'General',0),(108,8,'L7','Sleeper',0,'General',0),(109,10,'L7','Sleeper',0,'General',0),(110,12,'L7','Sleeper',0,'General',0),(111,13,'L7','Sleeper',0,'General',0),(112,15,'L7','Sleeper',0,'General',0),(113,16,'L7','Sleeper',0,'General',0),(114,19,'L7','Sleeper',0,'General',0),(115,21,'L7','Sleeper',0,'General',0),(116,23,'L7','Sleeper',0,'General',0),(117,24,'L7','Sleeper',0,'General',0),(118,27,'L7','Sleeper',0,'General',0),(119,28,'L7','Sleeper',0,'General',0),(120,1,'L8','Sleeper',0,'General',0),(121,3,'L8','Sleeper',0,'General',0),(122,4,'L8','Sleeper',0,'General',0),(123,5,'L8','Sleeper',0,'General',0),(124,6,'L8','Sleeper',0,'General',0),(125,8,'L8','Sleeper',0,'General',0),(126,10,'L8','Sleeper',0,'General',0),(127,12,'L8','Sleeper',0,'General',0),(128,13,'L8','Sleeper',0,'General',0),(129,15,'L8','Sleeper',0,'General',0),(130,16,'L8','Sleeper',0,'General',0),(131,19,'L8','Sleeper',0,'General',0),(132,21,'L8','Sleeper',0,'General',0),(133,23,'L8','Sleeper',0,'General',0),(134,24,'L8','Sleeper',0,'General',0),(135,27,'L8','Sleeper',0,'General',0),(136,28,'L8','Sleeper',0,'General',0),(137,1,'L9','Sleeper',0,'General',0),(138,3,'L9','Sleeper',0,'General',0),(139,4,'L9','Sleeper',0,'General',0),(140,5,'L9','Sleeper',0,'General',0),(141,6,'L9','Sleeper',0,'General',0),(142,8,'L9','Sleeper',0,'General',0),(143,10,'L9','Sleeper',0,'General',0),(144,12,'L9','Sleeper',0,'General',0),(145,13,'L9','Sleeper',0,'General',0),(146,15,'L9','Sleeper',0,'General',0),(147,16,'L9','Sleeper',0,'General',0),(148,19,'L9','Sleeper',0,'General',0),(149,21,'L9','Sleeper',0,'General',0),(150,23,'L9','Sleeper',0,'General',0),(151,24,'L9','Sleeper',0,'General',0),(152,27,'L9','Sleeper',0,'General',0),(153,28,'L9','Sleeper',0,'General',0),(154,1,'L10','Sleeper',0,'General',0),(155,3,'L10','Sleeper',0,'General',0),(156,4,'L10','Sleeper',0,'General',0),(157,5,'L10','Sleeper',0,'General',0),(158,6,'L10','Sleeper',0,'General',0),(159,8,'L10','Sleeper',0,'General',0),(160,10,'L10','Sleeper',0,'General',0),(161,12,'L10','Sleeper',0,'General',0),(162,13,'L10','Sleeper',0,'General',0),(163,15,'L10','Sleeper',0,'General',0),(164,16,'L10','Sleeper',0,'General',0),(165,19,'L10','Sleeper',0,'General',0),(166,21,'L10','Sleeper',0,'General',0),(167,23,'L10','Sleeper',0,'General',0),(168,24,'L10','Sleeper',0,'General',0),(169,27,'L10','Sleeper',0,'General',0),(170,28,'L10','Sleeper',0,'General',0),(171,1,'L11','Sleeper',0,'General',0),(172,3,'L11','Sleeper',0,'General',0),(173,4,'L11','Sleeper',0,'General',0),(174,5,'L11','Sleeper',0,'General',0),(175,6,'L11','Sleeper',0,'General',0),(176,8,'L11','Sleeper',0,'General',0),(177,10,'L11','Sleeper',0,'General',0),(178,12,'L11','Sleeper',0,'General',0),(179,13,'L11','Sleeper',0,'General',0),(180,15,'L11','Sleeper',0,'General',0),(181,16,'L11','Sleeper',0,'General',0),(182,19,'L11','Sleeper',0,'General',0),(183,21,'L11','Sleeper',0,'General',0),(184,23,'L11','Sleeper',0,'General',0),(185,24,'L11','Sleeper',0,'General',0),(186,27,'L11','Sleeper',0,'General',0),(187,28,'L11','Sleeper',0,'General',0),(188,1,'L12','Sleeper',0,'Female',0),(189,3,'L12','Sleeper',0,'Female',0),(190,4,'L12','Sleeper',0,'Female',0),(191,5,'L12','Sleeper',0,'Female',0),(192,6,'L12','Sleeper',0,'Female',0),(193,8,'L12','Sleeper',0,'Female',0),(194,10,'L12','Sleeper',0,'Female',0),(195,12,'L12','Sleeper',0,'Female',0),(196,13,'L12','Sleeper',0,'Female',0),(197,15,'L12','Sleeper',0,'Female',0),(198,16,'L12','Sleeper',0,'Female',0),(199,19,'L12','Sleeper',0,'Female',0),(200,21,'L12','Sleeper',0,'Female',0),(201,23,'L12','Sleeper',0,'Female',0),(202,24,'L12','Sleeper',0,'Female',0),(203,27,'L12','Sleeper',0,'Female',0),(204,28,'L12','Sleeper',0,'Female',0),(205,1,'L13','Sleeper',0,'General',0),(206,3,'L13','Sleeper',0,'General',0),(207,4,'L13','Sleeper',0,'General',0),(208,5,'L13','Sleeper',0,'General',0),(209,6,'L13','Sleeper',0,'General',0),(210,8,'L13','Sleeper',0,'General',0),(211,10,'L13','Sleeper',0,'General',0),(212,12,'L13','Sleeper',0,'General',0),(213,13,'L13','Sleeper',0,'General',0),(214,15,'L13','Sleeper',0,'General',0),(215,16,'L13','Sleeper',0,'General',0),(216,19,'L13','Sleeper',0,'General',0),(217,21,'L13','Sleeper',0,'General',0),(218,23,'L13','Sleeper',0,'General',0),(219,24,'L13','Sleeper',0,'General',0),(220,27,'L13','Sleeper',0,'General',0),(221,28,'L13','Sleeper',0,'General',0),(222,1,'L14','Sleeper',0,'General',0),(223,3,'L14','Sleeper',0,'General',0),(224,4,'L14','Sleeper',0,'General',0),(225,5,'L14','Sleeper',0,'General',0),(226,6,'L14','Sleeper',0,'General',0),(227,8,'L14','Sleeper',0,'General',0),(228,10,'L14','Sleeper',0,'General',0),(229,12,'L14','Sleeper',0,'General',0),(230,13,'L14','Sleeper',0,'General',0),(231,15,'L14','Sleeper',0,'General',0),(232,16,'L14','Sleeper',0,'General',0),(233,19,'L14','Sleeper',0,'General',0),(234,21,'L14','Sleeper',0,'General',0),(235,23,'L14','Sleeper',0,'General',0),(236,24,'L14','Sleeper',0,'General',0),(237,27,'L14','Sleeper',0,'General',0),(238,28,'L14','Sleeper',0,'General',0),(239,1,'L15','Sleeper',0,'General',0),(240,3,'L15','Sleeper',0,'General',0),(241,4,'L15','Sleeper',0,'General',0),(242,5,'L15','Sleeper',0,'General',0),(243,6,'L15','Sleeper',0,'General',0),(244,8,'L15','Sleeper',0,'General',0),(245,10,'L15','Sleeper',0,'General',0),(246,12,'L15','Sleeper',0,'General',0),(247,13,'L15','Sleeper',0,'General',0),(248,15,'L15','Sleeper',0,'General',0),(249,16,'L15','Sleeper',0,'General',0),(250,19,'L15','Sleeper',0,'General',0),(251,21,'L15','Sleeper',0,'General',0),(252,23,'L15','Sleeper',0,'General',0),(253,24,'L15','Sleeper',0,'General',0),(254,27,'L15','Sleeper',0,'General',0),(255,28,'L15','Sleeper',0,'General',0),(256,1,'U1','Sleeper',0,'General',0),(257,3,'U1','Sleeper',0,'General',0),(258,4,'U1','Sleeper',0,'General',0),(259,5,'U1','Sleeper',0,'General',0),(260,6,'U1','Sleeper',0,'General',0),(261,8,'U1','Sleeper',0,'General',0),(262,10,'U1','Sleeper',0,'General',0),(263,12,'U1','Sleeper',0,'General',0),(264,13,'U1','Sleeper',0,'General',0),(265,15,'U1','Sleeper',0,'General',0),(266,16,'U1','Sleeper',0,'General',0),(267,19,'U1','Sleeper',0,'General',0),(268,21,'U1','Sleeper',0,'General',0),(269,23,'U1','Sleeper',0,'General',0),(270,24,'U1','Sleeper',0,'General',0),(271,27,'U1','Sleeper',0,'General',0),(272,28,'U1','Sleeper',0,'General',0),(273,1,'U2','Sleeper',0,'General',0),(274,3,'U2','Sleeper',0,'General',0),(275,4,'U2','Sleeper',0,'General',0),(276,5,'U2','Sleeper',0,'General',0),(277,6,'U2','Sleeper',0,'General',0),(278,8,'U2','Sleeper',0,'General',0),(279,10,'U2','Sleeper',0,'General',0),(280,12,'U2','Sleeper',0,'General',0),(281,13,'U2','Sleeper',0,'General',0),(282,15,'U2','Sleeper',0,'General',0),(283,16,'U2','Sleeper',0,'General',0),(284,19,'U2','Sleeper',0,'General',0),(285,21,'U2','Sleeper',0,'General',0),(286,23,'U2','Sleeper',0,'General',0),(287,24,'U2','Sleeper',0,'General',0),(288,27,'U2','Sleeper',0,'General',0),(289,28,'U2','Sleeper',0,'General',0),(290,1,'U3','Sleeper',0,'General',0),(291,3,'U3','Sleeper',0,'General',0),(292,4,'U3','Sleeper',0,'General',0),(293,5,'U3','Sleeper',0,'General',0),(294,6,'U3','Sleeper',0,'General',0),(295,8,'U3','Sleeper',0,'General',0),(296,10,'U3','Sleeper',0,'General',0),(297,12,'U3','Sleeper',0,'General',0),(298,13,'U3','Sleeper',0,'General',0),(299,15,'U3','Sleeper',0,'General',0),(300,16,'U3','Sleeper',0,'General',0),(301,19,'U3','Sleeper',0,'General',0),(302,21,'U3','Sleeper',0,'General',0),(303,23,'U3','Sleeper',0,'General',0),(304,24,'U3','Sleeper',0,'General',0),(305,27,'U3','Sleeper',0,'General',0),(306,28,'U3','Sleeper',0,'General',0),(307,1,'U4','Sleeper',0,'General',0),(308,3,'U4','Sleeper',0,'General',0),(309,4,'U4','Sleeper',0,'General',0),(310,5,'U4','Sleeper',0,'General',0),(311,6,'U4','Sleeper',0,'General',0),(312,8,'U4','Sleeper',0,'General',0),(313,10,'U4','Sleeper',0,'General',0),(314,12,'U4','Sleeper',0,'General',0),(315,13,'U4','Sleeper',0,'General',0),(316,15,'U4','Sleeper',0,'General',0),(317,16,'U4','Sleeper',0,'General',0),(318,19,'U4','Sleeper',0,'General',0),(319,21,'U4','Sleeper',0,'General',0),(320,23,'U4','Sleeper',0,'General',0),(321,24,'U4','Sleeper',0,'General',0),(322,27,'U4','Sleeper',0,'General',0),(323,28,'U4','Sleeper',0,'General',0),(324,1,'U5','Sleeper',0,'General',0),(325,3,'U5','Sleeper',0,'General',0),(326,4,'U5','Sleeper',1,'General',0),(327,5,'U5','Sleeper',0,'General',0),(328,6,'U5','Sleeper',1,'General',0),(329,8,'U5','Sleeper',1,'General',0),(330,10,'U5','Sleeper',1,'General',0),(331,12,'U5','Sleeper',1,'General',0),(332,13,'U5','Sleeper',0,'General',0),(333,15,'U5','Sleeper',0,'General',0),(334,16,'U5','Sleeper',1,'General',0),(335,19,'U5','Sleeper',0,'General',0),(336,21,'U5','Sleeper',0,'General',0),(337,23,'U5','Sleeper',0,'General',0),(338,24,'U5','Sleeper',1,'General',0),(339,27,'U5','Sleeper',0,'General',0),(340,28,'U5','Sleeper',1,'General',0),(341,1,'U6','Sleeper',0,'General',0),(342,3,'U6','Sleeper',0,'General',0),(343,4,'U6','Sleeper',0,'General',0),(344,5,'U6','Sleeper',0,'General',0),(345,6,'U6','Sleeper',0,'General',0),(346,8,'U6','Sleeper',0,'General',0),(347,10,'U6','Sleeper',0,'General',0),(348,12,'U6','Sleeper',0,'General',0),(349,13,'U6','Sleeper',0,'General',0),(350,15,'U6','Sleeper',0,'General',0),(351,16,'U6','Sleeper',0,'General',0),(352,19,'U6','Sleeper',0,'General',0),(353,21,'U6','Sleeper',0,'General',0),(354,23,'U6','Sleeper',0,'General',0),(355,24,'U6','Sleeper',0,'General',0),(356,27,'U6','Sleeper',0,'General',0),(357,28,'U6','Sleeper',0,'General',0),(358,1,'U7','Sleeper',0,'General',0),(359,3,'U7','Sleeper',0,'General',0),(360,4,'U7','Sleeper',0,'General',0),(361,5,'U7','Sleeper',0,'General',0),(362,6,'U7','Sleeper',0,'General',0),(363,8,'U7','Sleeper',0,'General',0),(364,10,'U7','Sleeper',0,'General',0),(365,12,'U7','Sleeper',0,'General',0),(366,13,'U7','Sleeper',0,'General',0),(367,15,'U7','Sleeper',0,'General',0),(368,16,'U7','Sleeper',0,'General',0),(369,19,'U7','Sleeper',0,'General',0),(370,21,'U7','Sleeper',0,'General',0),(371,23,'U7','Sleeper',0,'General',0),(372,24,'U7','Sleeper',0,'General',0),(373,27,'U7','Sleeper',0,'General',0),(374,28,'U7','Sleeper',0,'General',0),(375,1,'U8','Sleeper',0,'General',0),(376,3,'U8','Sleeper',0,'General',0),(377,4,'U8','Sleeper',0,'General',0),(378,5,'U8','Sleeper',0,'General',0),(379,6,'U8','Sleeper',0,'General',0),(380,8,'U8','Sleeper',0,'General',0),(381,10,'U8','Sleeper',0,'General',0),(382,12,'U8','Sleeper',0,'General',0),(383,13,'U8','Sleeper',0,'General',0),(384,15,'U8','Sleeper',0,'General',0),(385,16,'U8','Sleeper',0,'General',0),(386,19,'U8','Sleeper',0,'General',0),(387,21,'U8','Sleeper',0,'General',0),(388,23,'U8','Sleeper',0,'General',0),(389,24,'U8','Sleeper',0,'General',0),(390,27,'U8','Sleeper',0,'General',0),(391,28,'U8','Sleeper',0,'General',0),(392,1,'U9','Sleeper',0,'General',0),(393,3,'U9','Sleeper',0,'General',0),(394,4,'U9','Sleeper',0,'General',0),(395,5,'U9','Sleeper',0,'General',0),(396,6,'U9','Sleeper',0,'General',0),(397,8,'U9','Sleeper',0,'General',0),(398,10,'U9','Sleeper',0,'General',0),(399,12,'U9','Sleeper',0,'General',0),(400,13,'U9','Sleeper',0,'General',0),(401,15,'U9','Sleeper',0,'General',0),(402,16,'U9','Sleeper',0,'General',0),(403,19,'U9','Sleeper',0,'General',0),(404,21,'U9','Sleeper',0,'General',0),(405,23,'U9','Sleeper',0,'General',0),(406,24,'U9','Sleeper',0,'General',0),(407,27,'U9','Sleeper',0,'General',0),(408,28,'U9','Sleeper',0,'General',0),(409,1,'U10','Sleeper',0,'General',0),(410,3,'U10','Sleeper',0,'General',0),(411,4,'U10','Sleeper',0,'General',0),(412,5,'U10','Sleeper',0,'General',0),(413,6,'U10','Sleeper',0,'General',0),(414,8,'U10','Sleeper',0,'General',0),(415,10,'U10','Sleeper',0,'General',0),(416,12,'U10','Sleeper',0,'General',0),(417,13,'U10','Sleeper',0,'General',0),(418,15,'U10','Sleeper',0,'General',0),(419,16,'U10','Sleeper',0,'General',0),(420,19,'U10','Sleeper',0,'General',0),(421,21,'U10','Sleeper',0,'General',0),(422,23,'U10','Sleeper',0,'General',0),(423,24,'U10','Sleeper',0,'General',0),(424,27,'U10','Sleeper',0,'General',0),(425,28,'U10','Sleeper',0,'General',0),(426,1,'U11','Sleeper',0,'General',0),(427,3,'U11','Sleeper',0,'General',0),(428,4,'U11','Sleeper',0,'General',0),(429,5,'U11','Sleeper',0,'General',0),(430,6,'U11','Sleeper',0,'General',0),(431,8,'U11','Sleeper',0,'General',0),(432,10,'U11','Sleeper',0,'General',0),(433,12,'U11','Sleeper',0,'General',0),(434,13,'U11','Sleeper',0,'General',0),(435,15,'U11','Sleeper',0,'General',0),(436,16,'U11','Sleeper',0,'General',0),(437,19,'U11','Sleeper',0,'General',0),(438,21,'U11','Sleeper',0,'General',0),(439,23,'U11','Sleeper',0,'General',0),(440,24,'U11','Sleeper',0,'General',0),(441,27,'U11','Sleeper',0,'General',0),(442,28,'U11','Sleeper',0,'General',0),(443,1,'U12','Sleeper',0,'General',0),(444,3,'U12','Sleeper',0,'General',0),(445,4,'U12','Sleeper',0,'General',0),(446,5,'U12','Sleeper',0,'General',0),(447,6,'U12','Sleeper',0,'General',0),(448,8,'U12','Sleeper',0,'General',0),(449,10,'U12','Sleeper',0,'General',0),(450,12,'U12','Sleeper',0,'General',0),(451,13,'U12','Sleeper',0,'General',0),(452,15,'U12','Sleeper',0,'General',0),(453,16,'U12','Sleeper',0,'General',0),(454,19,'U12','Sleeper',0,'General',0),(455,21,'U12','Sleeper',0,'General',0),(456,23,'U12','Sleeper',0,'General',0),(457,24,'U12','Sleeper',0,'General',0),(458,27,'U12','Sleeper',0,'General',0),(459,28,'U12','Sleeper',0,'General',0),(460,1,'U13','Sleeper',0,'General',0),(461,3,'U13','Sleeper',0,'General',0),(462,4,'U13','Sleeper',0,'General',0),(463,5,'U13','Sleeper',0,'General',0),(464,6,'U13','Sleeper',0,'General',0),(465,8,'U13','Sleeper',0,'General',0),(466,10,'U13','Sleeper',0,'General',0),(467,12,'U13','Sleeper',0,'General',0),(468,13,'U13','Sleeper',0,'General',0),(469,15,'U13','Sleeper',0,'General',0),(470,16,'U13','Sleeper',0,'General',0),(471,19,'U13','Sleeper',0,'General',0),(472,21,'U13','Sleeper',0,'General',0),(473,23,'U13','Sleeper',0,'General',0),(474,24,'U13','Sleeper',0,'General',0),(475,27,'U13','Sleeper',0,'General',0),(476,28,'U13','Sleeper',0,'General',0),(477,1,'U14','Sleeper',0,'General',0),(478,3,'U14','Sleeper',0,'General',0),(479,4,'U14','Sleeper',0,'General',0),(480,5,'U14','Sleeper',0,'General',0),(481,6,'U14','Sleeper',0,'General',0),(482,8,'U14','Sleeper',0,'General',0),(483,10,'U14','Sleeper',0,'General',0),(484,12,'U14','Sleeper',0,'General',0),(485,13,'U14','Sleeper',0,'General',0),(486,15,'U14','Sleeper',0,'General',0),(487,16,'U14','Sleeper',0,'General',0),(488,19,'U14','Sleeper',0,'General',0),(489,21,'U14','Sleeper',0,'General',0),(490,23,'U14','Sleeper',0,'General',0),(491,24,'U14','Sleeper',0,'General',0),(492,27,'U14','Sleeper',0,'General',0),(493,28,'U14','Sleeper',0,'General',0),(494,1,'U15','Sleeper',0,'General',0),(495,3,'U15','Sleeper',0,'General',0),(496,4,'U15','Sleeper',0,'General',0),(497,5,'U15','Sleeper',0,'General',0),(498,6,'U15','Sleeper',0,'General',0),(499,8,'U15','Sleeper',0,'General',0),(500,10,'U15','Sleeper',0,'General',0),(501,12,'U15','Sleeper',0,'General',0),(502,13,'U15','Sleeper',0,'General',0),(503,15,'U15','Sleeper',0,'General',0),(504,16,'U15','Sleeper',0,'General',0),(505,19,'U15','Sleeper',0,'General',0),(506,21,'U15','Sleeper',0,'General',0),(507,23,'U15','Sleeper',0,'General',0),(508,24,'U15','Sleeper',0,'General',0),(509,27,'U15','Sleeper',0,'General',0),(510,28,'U15','Sleeper',0,'General',0),(512,2,'1A','Seater',0,'General',0),(513,7,'1A','Seater',0,'General',0),(514,9,'1A','Seater',0,'General',0),(515,11,'1A','Seater',0,'General',0),(516,14,'1A','Seater',0,'General',0),(517,17,'1A','Seater',0,'General',0),(518,18,'1A','Seater',0,'General',0),(519,20,'1A','Seater',0,'General',0),(520,22,'1A','Seater',0,'General',0),(521,25,'1A','Seater',0,'General',0),(522,26,'1A','Seater',0,'General',0),(523,29,'1A','Seater',0,'General',0),(524,30,'1A','Seater',0,'General',0),(525,2,'1B','Seater',0,'General',0),(526,7,'1B','Seater',0,'General',0),(527,9,'1B','Seater',0,'General',0),(528,11,'1B','Seater',0,'General',0),(529,14,'1B','Seater',0,'General',0),(530,17,'1B','Seater',0,'General',0),(531,18,'1B','Seater',0,'General',0),(532,20,'1B','Seater',0,'General',0),(533,22,'1B','Seater',0,'General',0),(534,25,'1B','Seater',0,'General',0),(535,26,'1B','Seater',0,'General',0),(536,29,'1B','Seater',0,'General',0),(537,30,'1B','Seater',0,'General',0),(538,2,'1C','Seater',1,'General',0),(539,7,'1C','Seater',0,'General',0),(540,9,'1C','Seater',0,'General',0),(541,11,'1C','Seater',0,'General',0),(542,14,'1C','Seater',1,'General',0),(543,17,'1C','Seater',0,'General',0),(544,18,'1C','Seater',1,'General',0),(545,20,'1C','Seater',1,'General',0),(546,22,'1C','Seater',1,'General',0),(547,25,'1C','Seater',0,'General',0),(548,26,'1C','Seater',1,'General',0),(549,29,'1C','Seater',0,'General',0),(550,30,'1C','Seater',1,'General',0),(551,2,'1D','Seater',0,'General',0),(552,7,'1D','Seater',0,'General',0),(553,9,'1D','Seater',0,'General',0),(554,11,'1D','Seater',0,'General',0),(555,14,'1D','Seater',0,'General',0),(556,17,'1D','Seater',0,'General',0),(557,18,'1D','Seater',0,'General',0),(558,20,'1D','Seater',0,'General',0),(559,22,'1D','Seater',0,'General',0),(560,25,'1D','Seater',0,'General',0),(561,26,'1D','Seater',0,'General',0),(562,29,'1D','Seater',0,'General',0),(563,30,'1D','Seater',0,'General',0),(564,2,'2A','Seater',0,'Female',0),(565,7,'2A','Seater',0,'Female',0),(566,9,'2A','Seater',0,'Female',0),(567,11,'2A','Seater',0,'Female',0),(568,14,'2A','Seater',0,'Female',0),(569,17,'2A','Seater',0,'Female',0),(570,18,'2A','Seater',0,'Female',0),(571,20,'2A','Seater',0,'Female',0),(572,22,'2A','Seater',0,'Female',0),(573,25,'2A','Seater',0,'Female',0),(574,26,'2A','Seater',0,'Female',0),(575,29,'2A','Seater',0,'Female',0),(576,30,'2A','Seater',0,'Female',0),(577,2,'2B','Seater',0,'General',0),(578,7,'2B','Seater',0,'General',0),(579,9,'2B','Seater',0,'General',0),(580,11,'2B','Seater',0,'General',0),(581,14,'2B','Seater',0,'General',0),(582,17,'2B','Seater',0,'General',0),(583,18,'2B','Seater',0,'General',0),(584,20,'2B','Seater',0,'General',0),(585,22,'2B','Seater',0,'General',0),(586,25,'2B','Seater',0,'General',0),(587,26,'2B','Seater',0,'General',0),(588,29,'2B','Seater',0,'General',0),(589,30,'2B','Seater',0,'General',0),(590,2,'2C','Seater',0,'General',0),(591,7,'2C','Seater',0,'General',0),(592,9,'2C','Seater',0,'General',0),(593,11,'2C','Seater',0,'General',0),(594,14,'2C','Seater',0,'General',0),(595,17,'2C','Seater',0,'General',0),(596,18,'2C','Seater',0,'General',0),(597,20,'2C','Seater',0,'General',0),(598,22,'2C','Seater',0,'General',0),(599,25,'2C','Seater',0,'General',0),(600,26,'2C','Seater',0,'General',0),(601,29,'2C','Seater',0,'General',0),(602,30,'2C','Seater',0,'General',0),(603,2,'2D','Seater',0,'General',0),(604,7,'2D','Seater',0,'General',0),(605,9,'2D','Seater',0,'General',0),(606,11,'2D','Seater',0,'General',0),(607,14,'2D','Seater',0,'General',0),(608,17,'2D','Seater',0,'General',0),(609,18,'2D','Seater',0,'General',0),(610,20,'2D','Seater',0,'General',0),(611,22,'2D','Seater',0,'General',0),(612,25,'2D','Seater',0,'General',0),(613,26,'2D','Seater',0,'General',0),(614,29,'2D','Seater',0,'General',0),(615,30,'2D','Seater',0,'General',0),(616,2,'3A','Seater',0,'General',0),(617,7,'3A','Seater',0,'General',0),(618,9,'3A','Seater',0,'General',0),(619,11,'3A','Seater',0,'General',0),(620,14,'3A','Seater',0,'General',0),(621,17,'3A','Seater',0,'General',0),(622,18,'3A','Seater',0,'General',0),(623,20,'3A','Seater',0,'General',0),(624,22,'3A','Seater',0,'General',0),(625,25,'3A','Seater',0,'General',0),(626,26,'3A','Seater',0,'General',0),(627,29,'3A','Seater',0,'General',0),(628,30,'3A','Seater',0,'General',0),(629,2,'3B','Seater',0,'General',0),(630,7,'3B','Seater',0,'General',0),(631,9,'3B','Seater',0,'General',0),(632,11,'3B','Seater',0,'General',0),(633,14,'3B','Seater',0,'General',0),(634,17,'3B','Seater',0,'General',0),(635,18,'3B','Seater',0,'General',0),(636,20,'3B','Seater',0,'General',0),(637,22,'3B','Seater',0,'General',0),(638,25,'3B','Seater',0,'General',0),(639,26,'3B','Seater',0,'General',0),(640,29,'3B','Seater',0,'General',0),(641,30,'3B','Seater',0,'General',0),(642,2,'3C','Seater',0,'General',0),(643,7,'3C','Seater',0,'General',0),(644,9,'3C','Seater',0,'General',0),(645,11,'3C','Seater',0,'General',0),(646,14,'3C','Seater',0,'General',0),(647,17,'3C','Seater',0,'General',0),(648,18,'3C','Seater',0,'General',0),(649,20,'3C','Seater',0,'General',0),(650,22,'3C','Seater',0,'General',0),(651,25,'3C','Seater',0,'General',0),(652,26,'3C','Seater',0,'General',0),(653,29,'3C','Seater',0,'General',0),(654,30,'3C','Seater',0,'General',0),(655,2,'3D','Seater',0,'General',0),(656,7,'3D','Seater',0,'General',0),(657,9,'3D','Seater',0,'General',0),(658,11,'3D','Seater',0,'General',0),(659,14,'3D','Seater',0,'General',0),(660,17,'3D','Seater',0,'General',0),(661,18,'3D','Seater',0,'General',0),(662,20,'3D','Seater',0,'General',0),(663,22,'3D','Seater',0,'General',0),(664,25,'3D','Seater',0,'General',0),(665,26,'3D','Seater',0,'General',0),(666,29,'3D','Seater',0,'General',0),(667,30,'3D','Seater',0,'General',0),(668,2,'4A','Seater',0,'General',0),(669,7,'4A','Seater',0,'General',0),(670,9,'4A','Seater',0,'General',0),(671,11,'4A','Seater',0,'General',0),(672,14,'4A','Seater',0,'General',0),(673,17,'4A','Seater',0,'General',0),(674,18,'4A','Seater',0,'General',0),(675,20,'4A','Seater',0,'General',0),(676,22,'4A','Seater',0,'General',0),(677,25,'4A','Seater',0,'General',0),(678,26,'4A','Seater',0,'General',0),(679,29,'4A','Seater',0,'General',0),(680,30,'4A','Seater',0,'General',0),(681,2,'4B','Seater',0,'General',0),(682,7,'4B','Seater',0,'General',0),(683,9,'4B','Seater',0,'General',0),(684,11,'4B','Seater',0,'General',0),(685,14,'4B','Seater',0,'General',0),(686,17,'4B','Seater',0,'General',0),(687,18,'4B','Seater',0,'General',0),(688,20,'4B','Seater',0,'General',0),(689,22,'4B','Seater',0,'General',0),(690,25,'4B','Seater',0,'General',0),(691,26,'4B','Seater',0,'General',0),(692,29,'4B','Seater',0,'General',0),(693,30,'4B','Seater',0,'General',0),(694,2,'4C','Seater',0,'General',0),(695,7,'4C','Seater',0,'General',0),(696,9,'4C','Seater',0,'General',0),(697,11,'4C','Seater',0,'General',0),(698,14,'4C','Seater',0,'General',0),(699,17,'4C','Seater',0,'General',0),(700,18,'4C','Seater',0,'General',0),(701,20,'4C','Seater',0,'General',0),(702,22,'4C','Seater',0,'General',0),(703,25,'4C','Seater',0,'General',0),(704,26,'4C','Seater',0,'General',0),(705,29,'4C','Seater',0,'General',0),(706,30,'4C','Seater',0,'General',0),(707,2,'4D','Seater',0,'General',0),(708,7,'4D','Seater',0,'General',0),(709,9,'4D','Seater',0,'General',0),(710,11,'4D','Seater',0,'General',0),(711,14,'4D','Seater',0,'General',0),(712,17,'4D','Seater',0,'General',0),(713,18,'4D','Seater',0,'General',0),(714,20,'4D','Seater',0,'General',0),(715,22,'4D','Seater',0,'General',0),(716,25,'4D','Seater',0,'General',0),(717,26,'4D','Seater',0,'General',0),(718,29,'4D','Seater',0,'General',0),(719,30,'4D','Seater',0,'General',0);
/*!40000 ALTER TABLE `seats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `mobile` varchar(15) DEFAULT NULL,
  `role` enum('User','Admin') DEFAULT 'User',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Tanvi Salve','tanvi@gmail.com','tanvi123','8291616525','User','2026-03-19 06:54:33'),(2,'Admin User','admin@bus.com','admin123','9999999999','User','2026-03-19 06:54:33');
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

-- Dump completed on 2026-03-19 12:58:05

/*!40101 SET @ObeyondcloudLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- beyondcloud 데이터베이스 구조 내보내기
CREATE DATABASE IF NOT EXISTS `beyondcloud` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `beyondcloud`;

CREATE TABLE IF NOT EXISTS `Role` (
    `role_code` INT NOT NULL,
    `name` VARCHAR(10) NOT NULL,
    PRIMARY KEY (`role_code`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `Role` (`role_code`, `name`) VALUES
	(0, 'user'),
	(1, 'admin'),
	(2, 'artist');

CREATE TABLE if NOT exists `Member` (
	`member_id`	bigint	NOT NULL auto_increment,
	`password`	varchar(20)	NOT NULL,
	`name`	varchar(10)	NOT NULL,
	`isLogin`	tinyint	NOT NULL	DEFAULT 0,
	`reg_date`	Date	NOT NULL	DEFAULT CURDATE(),
	`email`	varchar(50)	NOT NULL,
	`nickname`	varchar(50)	NOT NULL,
	`role_code`	int	NOT NULL	DEFAULT 0,
	PRIMARY KEY(`member_id`),
	FOREIGN KEY (`role_code`) REFERENCES `Role` (`role_code`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `PlayList` (
	`playList_id`	bigint NOT NULL AUTO_INCREMENT,
	`name`	varchar(50)	NOT NULL,
	`isPublic`	tinyint	NOT NULL	DEFAULT 0,
	`reg_date`	Date	NOT NULL	DEFAULT CURDATE(),
	`member_id`	bigint	NOT NULL,
	PRIMARY KEY(`playList_id`),
	FOREIGN KEY (`member_id`) REFERENCES `Member` (`member_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `Album` (
	`album_id`	bigint	NOT NULL AUTO_INCREMENT,
	`name`	varchar(50)	NOT NULL,
	`member_id`	bigint	NOT NULL,
	`Field`	tinyint(1)	NOT NULL	DEFAULT 0,
	`rel_date`	datetime	NOT NULL,
	PRIMARY KEY(`album_id`),
	FOREIGN KEY (`member_id`) REFERENCES `Member` (`member_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE `Song` (
	`song_id`	bigint	NOT NULL AUTO_INCREMENT,
	`name`	varchar(20)	NOT NULL,
	`genre`	varchar(10)	NOT NULL,
	`Streaming_cnt`	int	NOT NULL	DEFAULT 0,
	`album_id`	bigint	NOT NULL,
	`length`	int	NOT NULL,
	PRIMARY KEY(`song_id`),
	FOREIGN KEY (`album_id`) REFERENCES `Album` (`album_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `Comment` (
	`comment_id`	bigint	NOT NULL AUTO_INCREMENT,
	`content`	varchar(255)	NOT NULL,
	`write_date`	Date	NOT NULL	DEFAULT CURDATE(),
	`member_id`	bigint	NOT NULL,
	`song_id`	bigint	NOT NULL,
	PRIMARY KEY(`comment_id`),
	FOREIGN KEY (`member_id`) REFERENCES `Member` (`member_id`),
   FOREIGN KEY (`song_id`) REFERENCES `Song` (`song_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `NowPlayList` (
	`nowPlayList_id`	bigint	NOT NULL AUTO_INCREMENT,
	`member_id`	bigint	NOT NULL,
	PRIMARY KEY(`nowPlayList_id`),
	FOREIGN KEY (`member_id`) REFERENCES `Member` (`member_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `Song_In_NowPlayList` (
	`sin_id`	bigint	NOT NULL AUTO_INCREMENT,
	`nowPlayList_id`	bigint	NOT NULL,
	`song_id`	bigint	NOT NULL,
	`reg_date`	datetime	NOT NULL	DEFAULT NOW(),
	PRIMARY KEY(`sin_id`),
	FOREIGN KEY (`nowPlayList_id`) REFERENCES `NowPlayList` (`nowPlayList_id`),
   FOREIGN KEY (`song_id`) REFERENCES `Song` (`song_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `Chart` (
	`chart_id`	bigint	NOT NULL AUTO_INCREMENT,
	`name`	varchar(10)	NOT NULL,
	PRIMARY KEY(`chart_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `Song_In_Chart` (
	`sic_id`	bigint	NOT NULL AUTO_INCREMENT,
	`chart_id`	bigint	NOT NULL,
	`song_id`	bigint	NOT NULL,
	PRIMARY KEY(`sic_id`),
	FOREIGN KEY (`chart_id`) REFERENCES `Chart` (`chart_id`),
   FOREIGN KEY (`song_id`) REFERENCES `Song` (`song_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `Song_In_Playlist` (
	`sip_id`	bigint	NOT NULL AUTO_INCREMENT,
	`playList_id`	bigint	NOT NULL,
	`song_id`	bigint	NOT NULL,
	PRIMARY KEY(`sip_id`),
	FOREIGN KEY (`playList_id`) REFERENCES `PlayList` (`playList_id`),
   FOREIGN KEY (`song_id`) REFERENCES `Song` (`song_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `Streaming_count_by_member` (
	`Streaming_count`	bigint	NOT NULL AUTO_INCREMENT,
	`member_id`	bigint	NOT NULL,
	`song_id`	bigint	NOT NULL,
	`Streaming_dateTime`	Date	NOT NULL	DEFAULT CURDATE(),
	PRIMARY KEY(`Streaming_count`),
	FOREIGN KEY (`member_id`) REFERENCES `Member` (`member_id`),
   FOREIGN KEY (`song_id`) REFERENCES `Song` (`song_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `like_cnt` (
	`like_cnt_id`	bigint	NOT NULL AUTO_INCREMENT,
	`member_id`	bigint	NOT NULL,
	`album_id`	bigint	NOT NULL,
	PRIMARY KEY(`like_cnt_id`),
	FOREIGN KEY (`member_id`) REFERENCES `Member` (`member_id`),
   FOREIGN KEY (`album_id`) REFERENCES `Album` (`album_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `Listening_song` (
	`Listening_song_id`	bigint	NOT NULL AUTO_INCREMENT,
	`nowPlayList_id`	bigint	NOT NULL,
	PRIMARY KEY(`Listening_song_id`),
	FOREIGN KEY (`nowPlayList_id`) REFERENCES `NowPlayList` (`nowPlayList_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



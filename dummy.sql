-- --------------------------------------------------------
-- 호스트:                          beyondclouddb.cj4mw46g2m7w.us-east-2.rds.amazonaws.com
-- 서버 버전:                        10.4.34-MariaDB-log - Source distribution
-- 서버 OS:                        Linux
-- HeidiSQL 버전:                  12.7.0.6850
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- beyondcloud 데이터베이스 구조 내보내기
CREATE DATABASE IF NOT EXISTS `beyondcloud` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `beyondcloud`;

-- 테이블 beyondcloud.Album 구조 내보내기
CREATE TABLE IF NOT EXISTS `Album` (
  `album_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `artist_name` varchar(20) NOT NULL,
  `al_count` int(11) NOT NULL DEFAULT 0,
  `r_date` date NOT NULL DEFAULT curdate(),
  PRIMARY KEY (`album_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.Album:~0 rows (대략적) 내보내기
DELETE FROM `Album`;

-- 테이블 beyondcloud.Chart 구조 내보내기
CREATE TABLE IF NOT EXISTS `Chart` (
  `chart_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(10) NOT NULL,
  PRIMARY KEY (`chart_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.Chart:~0 rows (대략적) 내보내기
DELETE FROM `Chart`;

-- 테이블 beyondcloud.Comment 구조 내보내기
CREATE TABLE IF NOT EXISTS `Comment` (
  `comment_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `content` varchar(150) NOT NULL,
  `write_date` date NOT NULL DEFAULT curdate(),
  `member_id` bigint(20) NOT NULL,
  `song_id` bigint(20) NOT NULL,
  PRIMARY KEY (`comment_id`),
  KEY `FK_Member_TO_Comment_1` (`member_id`),
  KEY `FK_Song_TO_Comment_1` (`song_id`),
  CONSTRAINT `FK_Member_TO_Comment_1` FOREIGN KEY (`member_id`) REFERENCES `Member` (`member_id`),
  CONSTRAINT `FK_Song_TO_Comment_1` FOREIGN KEY (`song_id`) REFERENCES `Song` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.Comment:~0 rows (대략적) 내보내기
DELETE FROM `Comment`;

-- 테이블 beyondcloud.Member 구조 내보내기
CREATE TABLE IF NOT EXISTS `Member` (
  `member_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `password` varchar(20) NOT NULL,
  `name` varchar(20) NOT NULL,
  `isLogin` tinyint(1) NOT NULL DEFAULT 0,
  `reg_date` date NOT NULL DEFAULT curdate(),
  `email` varchar(255) NOT NULL,
  `nickname` varchar(50) NOT NULL,
  `role` varchar(5) NOT NULL DEFAULT 'User',
  PRIMARY KEY (`member_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.Member:~0 rows (대략적) 내보내기
DELETE FROM `Member`;
INSERT INTO `Member` (`member_id`, `password`, `name`, `isLogin`, `reg_date`, `email`, `nickname`, `role`) VALUES
	(2, '1234', 'cha', 0, '2024-12-23', 'cha', 'cha', 'User');

-- 테이블 beyondcloud.NowPlayList 구조 내보내기
CREATE TABLE IF NOT EXISTS `NowPlayList` (
  `nowPlayList_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `member_id` bigint(20) NOT NULL,
  PRIMARY KEY (`nowPlayList_id`),
  KEY `FK_Member_TO_NowPlayList_1` (`member_id`),
  CONSTRAINT `FK_Member_TO_NowPlayList_1` FOREIGN KEY (`member_id`) REFERENCES `Member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.NowPlayList:~0 rows (대략적) 내보내기
DELETE FROM `NowPlayList`;

-- 테이블 beyondcloud.PlayList 구조 내보내기
CREATE TABLE IF NOT EXISTS `PlayList` (
  `playList_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `isPublic` tinyint(1) NOT NULL DEFAULT 0,
  `reg_date` date NOT NULL DEFAULT curdate(),
  `member_id` bigint(20) NOT NULL,
  PRIMARY KEY (`playList_id`),
  KEY `FK_Member_TO_PlayList_1` (`member_id`),
  CONSTRAINT `FK_Member_TO_PlayList_1` FOREIGN KEY (`member_id`) REFERENCES `Member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.PlayList:~0 rows (대략적) 내보내기
DELETE FROM `PlayList`;

-- 테이블 beyondcloud.Song 구조 내보내기
CREATE TABLE IF NOT EXISTS `Song` (
  `song_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `genre` varchar(10) DEFAULT NULL,
  `good_cnt` bigint(20) NOT NULL DEFAULT 0,
  `Streaming_cnt` bigint(20) NOT NULL DEFAULT 0,
  `album_id` bigint(20) NOT NULL,
  PRIMARY KEY (`song_id`),
  KEY `FK_Album_TO_Song_1` (`album_id`),
  CONSTRAINT `FK_Album_TO_Song_1` FOREIGN KEY (`album_id`) REFERENCES `Album` (`album_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.Song:~0 rows (대략적) 내보내기
DELETE FROM `Song`;

-- 테이블 beyondcloud.Song_In_Chart 구조 내보내기
CREATE TABLE IF NOT EXISTS `Song_In_Chart` (
  `sic_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `chart_id` bigint(20) NOT NULL,
  `song_id` bigint(20) NOT NULL,
  PRIMARY KEY (`sic_id`),
  KEY `FK_Chart_TO_Song_In_Chart_1` (`chart_id`),
  KEY `FK_Song_TO_Song_In_Chart_1` (`song_id`),
  CONSTRAINT `FK_Chart_TO_Song_In_Chart_1` FOREIGN KEY (`chart_id`) REFERENCES `Chart` (`chart_id`),
  CONSTRAINT `FK_Song_TO_Song_In_Chart_1` FOREIGN KEY (`song_id`) REFERENCES `Song` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.Song_In_Chart:~0 rows (대략적) 내보내기
DELETE FROM `Song_In_Chart`;

-- 테이블 beyondcloud.Song_In_NowPlayList 구조 내보내기
CREATE TABLE IF NOT EXISTS `Song_In_NowPlayList` (
  `sin_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `nowPlayList_id` bigint(20) NOT NULL,
  `song_id` bigint(20) NOT NULL,
  PRIMARY KEY (`sin_id`),
  KEY `FK_NowPlayList_TO_Song_In_NowPlayList_1` (`nowPlayList_id`),
  KEY `FK_Song_TO_Song_In_NowPlayList_1` (`song_id`),
  CONSTRAINT `FK_NowPlayList_TO_Song_In_NowPlayList_1` FOREIGN KEY (`nowPlayList_id`) REFERENCES `NowPlayList` (`nowPlayList_id`),
  CONSTRAINT `FK_Song_TO_Song_In_NowPlayList_1` FOREIGN KEY (`song_id`) REFERENCES `Song` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.Song_In_NowPlayList:~0 rows (대략적) 내보내기
DELETE FROM `Song_In_NowPlayList`;

-- 테이블 beyondcloud.Song_In_Playlist 구조 내보내기
CREATE TABLE IF NOT EXISTS `Song_In_Playlist` (
  `sip_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `playList_id` bigint(20) NOT NULL,
  `song_id` bigint(20) NOT NULL,
  PRIMARY KEY (`sip_id`),
  KEY `FK_PlayList_TO_Song_In_Playlist_1` (`playList_id`),
  KEY `FK_Song_TO_Song_In_Playlist_1` (`song_id`),
  CONSTRAINT `FK_PlayList_TO_Song_In_Playlist_1` FOREIGN KEY (`playList_id`) REFERENCES `PlayList` (`playList_id`),
  CONSTRAINT `FK_Song_TO_Song_In_Playlist_1` FOREIGN KEY (`song_id`) REFERENCES `Song` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.Song_In_Playlist:~0 rows (대략적) 내보내기
DELETE FROM `Song_In_Playlist`;

-- 테이블 beyondcloud.Streaming_count_by_member 구조 내보내기
CREATE TABLE IF NOT EXISTS `Streaming_count_by_member` (
  `Streaming_count` bigint(20) NOT NULL AUTO_INCREMENT,
  `member_id` bigint(20) NOT NULL,
  `song_id` bigint(20) NOT NULL,
  `Streaming_dateTime` date NOT NULL DEFAULT curdate(),
  PRIMARY KEY (`Streaming_count`),
  KEY `FK_Member_TO_Streaming_count_by_member_1` (`member_id`),
  KEY `FK_Song_TO_Streaming_count_by_member_1` (`song_id`),
  CONSTRAINT `FK_Member_TO_Streaming_count_by_member_1` FOREIGN KEY (`member_id`) REFERENCES `Member` (`member_id`),
  CONSTRAINT `FK_Song_TO_Streaming_count_by_member_1` FOREIGN KEY (`song_id`) REFERENCES `Song` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- 테이블 데이터 beyondcloud.Streaming_count_by_member:~0 rows (대략적) 내보내기
DELETE FROM `Streaming_count_by_member`;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

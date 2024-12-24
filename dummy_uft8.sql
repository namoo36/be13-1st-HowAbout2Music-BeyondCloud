-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS beyondcloud
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

USE beyondcloud;

-- Member 테이블 생성
CREATE TABLE IF NOT EXISTS Member (
  member_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  password VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  name VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  isLogin TINYINT(1) NOT NULL DEFAULT 0,
  reg_date DATE NOT NULL DEFAULT CURDATE(),
  email VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  nickname VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  role VARCHAR(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'User'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Album 테이블 생성
CREATE TABLE IF NOT EXISTS Album (
  album_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  artist_name VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  al_count INT(11) NOT NULL DEFAULT 0,
  r_date DATE NOT NULL DEFAULT CURDATE()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Song 테이블 생성
CREATE TABLE IF NOT EXISTS Song (
  song_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  genre VARCHAR(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  good_cnt BIGINT NOT NULL DEFAULT 0,
  Streaming_cnt BIGINT NOT NULL DEFAULT 0,
  album_id BIGINT NOT NULL,
  CONSTRAINT FK_Album_TO_Song FOREIGN KEY (album_id) REFERENCES Album(album_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- PlayList 테이블 생성
CREATE TABLE IF NOT EXISTS PlayList (
  playList_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  isPublic TINYINT(1) NOT NULL DEFAULT 0,
  reg_date DATE NOT NULL DEFAULT CURDATE(),
  member_id BIGINT NOT NULL,
  CONSTRAINT FK_Member_TO_PlayList FOREIGN KEY (member_id) REFERENCES Member(member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- NowPlayList 테이블 생성
CREATE TABLE IF NOT EXISTS NowPlayList (
  nowPlayList_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  member_id BIGINT NOT NULL,
  CONSTRAINT FK_Member_TO_NowPlayList FOREIGN KEY (member_id) REFERENCES Member(member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Chart 테이블 생성
CREATE TABLE IF NOT EXISTS Chart (
  chart_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Comment 테이블 생성
CREATE TABLE IF NOT EXISTS Comment (
  comment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  content VARCHAR(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  write_date DATE NOT NULL DEFAULT CURDATE(),
  member_id BIGINT NOT NULL,
  song_id BIGINT NOT NULL,
  CONSTRAINT FK_Member_TO_Comment FOREIGN KEY (member_id) REFERENCES Member(member_id),
  CONSTRAINT FK_Song_TO_Comment FOREIGN KEY (song_id) REFERENCES Song(song_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Song_In_Playlist 테이블 생성
CREATE TABLE IF NOT EXISTS Song_In_Playlist (
  sip_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  playList_id BIGINT NOT NULL,
  song_id BIGINT NOT NULL,
  CONSTRAINT FK_PlayList_TO_Song_In_Playlist FOREIGN KEY (playList_id) REFERENCES PlayList(playList_id),
  CONSTRAINT FK_Song_TO_Song_In_Playlist FOREIGN KEY (song_id) REFERENCES Song(song_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Song_In_NowPlayList 테이블 생성
CREATE TABLE IF NOT EXISTS Song_In_NowPlayList (
  sin_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  nowPlayList_id BIGINT NOT NULL,
  song_id BIGINT NOT NULL,
  CONSTRAINT FK_NowPlayList_TO_Song_In_NowPlayList FOREIGN KEY (nowPlayList_id) REFERENCES NowPlayList(nowPlayList_id),
  CONSTRAINT FK_Song_TO_Song_In_NowPlayList FOREIGN KEY (song_id) REFERENCES Song(song_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Song_In_Chart 테이블 생성
CREATE TABLE IF NOT EXISTS Song_In_Chart (
  sic_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  chart_id BIGINT NOT NULL,
  song_id BIGINT NOT NULL,
  CONSTRAINT FK_Chart_TO_Song_In_Chart FOREIGN KEY (chart_id) REFERENCES Chart(chart_id),
  CONSTRAINT FK_Song_TO_Song_In_Chart FOREIGN KEY (song_id) REFERENCES Song(song_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Streaming_count_by_member 테이블 생성
CREATE TABLE IF NOT EXISTS Streaming_count_by_member (
  Streaming_count BIGINT AUTO_INCREMENT PRIMARY KEY,
  member_id BIGINT NOT NULL,
  song_id BIGINT NOT NULL,
  Streaming_dateTime DATE NOT NULL DEFAULT CURDATE(),
  CONSTRAINT FK_Member_TO_Streaming_count_by_member FOREIGN KEY (member_id) REFERENCES Member(member_id),
  CONSTRAINT FK_Song_TO_Streaming_count_by_member FOREIGN KEY (song_id) REFERENCES Song(song_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


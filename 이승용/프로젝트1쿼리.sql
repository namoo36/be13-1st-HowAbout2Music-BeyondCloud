USE beyondcloud;

-- 스케줄러 ON
SHOW VARIABLES LIKE 'event_scheduler';
SET GLOBAL event_scheduler = ON;



-- 개인 유저 별 플레이리스트 생성 프로시저

-- < 개인 회원 플레이리스트 생성 >
--  유저 아이디/ 플리 이름/공유유무만 받아서 새롭게 생성 
--  공유 유무에 NULL값(아무런 값을 받지 않는다고 가정)을 받을 경우 default 값으로 설정
--  최근 수정일은 디폴트 값(현재 시간)으로 정함.
--  이미 있는 플리 이름이면 오류 뜨게

DELIMITER $$
CREATE OR REPLACE PROCEDURE make_playlist(
	IN uid BIGINT(20), 
	IN play_list_name VARCHAR(20),
	IN is_shared TINYINT(1)
)

BEGIN 

DECLARE p_name VARCHAR(20);

	SELECT NAME INTO p_name
	FROM playlist
	WHERE member_id = uid AND NAME = play_list_name;
	
	IF p_name IS NOT NULL
	THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 있는 이름입니다.';
	ELSE
		SET is_shared = IFNULL(is_shared, 0);
		INSERT INTO playlist(`name`, member_id, isPublic) 
		VALUES(play_list_name, uid, is_shared);
	END IF;
END $$
DELIMITER ;




-- < 노래를 플레이리스트에 담기> 
--  유저 아이디, 플레이리스트(아이디 or 이름?), 노래 아이디를 받아서 담기
--  노래가 중복되어서는 안됨. 
DELIMITER $$
CREATE OR REPLACE PROCEDURE add_song_to_playlist(
		IN uid BIGINT(20),
		IN ply_id BIGINT(20),
		IN song_id BIGINT (20)
)
BEGIN 
	-- 만약 song_in_playlist에서 특정 플리 아이디의 해당 노래 아이디가 없을 경우-
	IF NOT EXISTS (
		SELECT *
		FROM song_in_playlist AS s
		WHERE s.playList_id = ply_id AND s.song_id = song_id
	) 
	THEN
		INSERT INTO song_in_playlist(playList_id, song_id) 
		VALUES(ply_id, song_id);
	ELSE 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '이미 존재하는 곡입니다.';
	END IF;
END $$
DELIMITER ;


-- < 아티스트 승인이 된 유저는 노래를 등록할 수 있다. -> 앨범부터 등록하도록(한 곡) > 
-- 유저 아이디, 노래 이름, 장르, 앨범 이름, 노래 시간 입력 받기
-- 해당 아이디의 역할이 아티스트이면 노래 인서트 가능,
-- 아닐 경우 멘트 출력

DELIMITER $$
CREATE OR REPLACE PROCEDURE insert_one_song_only_artist(
	IN uid BIGINT (20),
	IN s_name VARCHAR (30),
	IN s_genre VARCHAR(10),
	IN a_name VARCHAR (50),
	IN s_time INT -- > 노래 시간 받기
)
BEGIN 
	DECLARE u_role INT;
	DECLARE new_album_id BIGINT(20);
	
	SELECT role_code INTO u_role
	FROM member
	WHERE member_id = uid;
	
	IF u_role = 2 THEN
			-- 앨범 먼저 등록-> 앨범 이름이랑 아티스트 아이디 등록
			INSERT INTO album(NAME, member_id) VALUES(a_name, uid);
			
			-- 현재 세션 기반 가장 최근에 등록된 앨범의 아이디를 new_album_id에 저장
			SET new_album_id = LAST_INSERT_ID();
			
			-- 노래를 해당 앨범 아이디에 저장
			INSERT INTO song(`name`, genre, album_id, LENGTH) 
			VALUES(s_name, s_genre, new_album_id, s_time);
	ELSE 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '일반 유저는 노래를 추가할 수 없습니다.';
	END IF;
END $$
DELIMITER ;




-- < 아티스트 승인이 된 유저는 노래를 등록할 수 있다.(여러 곡) > 
-- 유저 아이디, 노래 이름, 앨범 이름 입력 받기
-- 해당 아이디의 역할이 아티스트이면 노래 인서트 가능,
-- 아닐 경우 멘트 출력

DELIMITER $$
CREATE OR REPLACE PROCEDURE insert_songs_only_artist(
	IN uid BIGINT (20),
	IN s_name TEXT,   -- > 노래 이름 받기(,  기준으로 받기) -> (435, 3235, 34254,2353245)
	IN s_genre VARCHAR(10),
	IN a_name VARCHAR (50),
	IN s_time TEXT -- > 노래 시간 받기(, 기준으로 시간 맞춰서)
)
BEGIN 
	DECLARE u_role INT;
	DECLARE song_count INT;
	DECLARE song_title VARCHAR(30);
	DECLARE song_time INT;
	DECLARE new_album_id BIGINT(20);
	
	SELECT role_code INTO u_role
	FROM member
	WHERE member_id = uid;
	
	SET song_count = 1;
	
	IF u_role = 2 THEN
	
			-- 앨범을 먼저 등록하기
			INSERT INTO album(NAME, member_id) VALUES(a_name, uid);
			
			-- 현 세션에서 가장 최근에 업데이트된 앨범의 아이디 받기
			SELECT album_id INTO new_album_id
			FROM album
			WHERE NAME = a_name;
			
		-- , 기준으로 나눠진 텍스트로 받은 값을 나눠서 노래를 앨범에 저장
		WHILE song_count <= LENGTH(s_name) - LENGTH(REPLACE(s_name, ',', '')) + 1
		DO 
			SET song_title = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(s_name, ',', song_count), ',', -1));
			SET song_time = CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(s_time, ',', song_count), ',', -1)) AS INT);
			
			INSERT INTO song(`name`, genre, album_id, LENGTH) 
			VALUES(song_title, s_genre, new_album_id, song_time);
			
			SET song_count = song_count + 1;
		END WHILE;
	ELSE 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '일반 유저는 노래를 추가할 수 없습니다.';
			-- 오류 처리 구문 
			-- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '일반 유저는 노래를 추가할 수 없습니다.';
	END IF;
END $$
DELIMITER ;




-- < 내가 올린 노래면 수정 삭제가 가능함 >

--  1) 노래삭제
-- 	 유저아이디, 노래 이름 입력 받기(동일 유저의 동일한 노래 입력은 없다고 가정?)
--     앨범이랑 유저 아이디랑 연결되어 있다고 가정
--     차라리 유저 아이디가 아티스트인 사람의 노래 목록 중에서
--     입력받은 노래 이름이 있는지 확인하는건?

DELIMITER $$
CREATE OR REPLACE PROCEDURE my_song_del(
	IN uid BIGINT (20),
	IN song_name VARCHAR (30)
)
BEGIN 
	DECLARE u_role INT;     
	DECLARE song_u_id BIGINT (20);
	
	-- 해당 아이디의 유저가 아티스트인지 확인
	SELECT role_code INTO u_role
	FROM member
	WHERE member_id = uid;	
	
	IF u_role = 2 THEN
	
		-- 해당 유저가 저장한 노래의 u_id를 확인
		SELECT s.song_id INTO song_u_id
		FROM song AS s 
		JOIN album AS a ON s.album_id = a.album_id
		WHERE a.member_id = uid AND s.name = song_name;
		
		
		IF ISNULL(song_u_id) THEN 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '삭제 권한이 없습니다.';
			
		ELSE 
			-- 노래가 존재할 경우 해당 노래를 삭제
			DELETE FROM song
			WHERE song_id = song_u_id;
			
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '노래가 제거되었습니다.';
			
		END IF;

	ELSE 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '일반 유저는 노래를 삭제할 수 없습니다.';

	END IF;
END $$
DELIMITER ;


-- 2) 노래 수정 -> 업데이트(노래 제목, 장르, (시간?) )
DELIMITER $$

CREATE OR REPLACE PROCEDURE my_song_edit(
	IN uid BIGINT (20),
	IN old_song_name VARCHAR(30),
	IN edit_song_name VARCHAR (30),
	IN edit_song_genre VARCHAR (10),
	IN song_time INT
)
BEGIN 
	DECLARE u_role INT;
	DECLARE song_u_id BIGINT (20);
	
	-- 해당 아이디의 유저가 아티스트인지 확인
	SELECT role_code INTO u_role
	FROM member
	WHERE member_id = uid;	
	
	IF u_role = 2 THEN
	
		-- 유저의 노래 제목에 맞는 노래 아이디를 조회
		SELECT song_id INTO song_u_id
		FROM song AS s
		JOIN album AS a ON s.album_id = a.album_id
		WHERE a.member_id = uid AND s.name = old_song_name;
		
		IF ISNULL(song_u_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '해당 노래가 존재하지 않거나 수정할 수 없습니다.';			
		ELSE 
			UPDATE song
			SET name = edit_song_name, genre = edit_song_genre, LENGTH = song_time
			WHERE song_id = song_u_id;	
		END IF;

	ELSE 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '일반 유저는 노래를 수정할 수 없습니다.';

	END IF;
END $$

DELIMITER ;


-- < 노래에 대한 댓글 달기 가능, 여러번 가능 > 
--   유저 아이디, 노래 아이디(이름), 댓글 내용 입력 받기
DELIMITER $$
CREATE OR REPLACE PROCEDURE user_comment(
	IN uid BIGINT (20),
	IN s_id BIGINT (20),
	IN c_contents VARCHAR(150)
)
BEGIN 
	INSERT INTO comment(content, member_id, song_id)
   VALUES (c_contents, uid, s_id);
END $$
DELIMITER ;



-- < 노래에 대한 댓글 삭제 가능 > 
--   유저 아이디, 댓글 아이디 입력 받아서 삭제 가능.
DELIMITER $$
CREATE OR REPLACE PROCEDURE user_comment_del(
	IN uid BIGINT (20),
	IN c_id BIGINT (20)
)
BEGIN 
	DELETE FROM comment WHERE comment_id = c_id;
END $$
DELIMITER ;


-- < 앨범에 대한 좋아요 남기기 가능- 계정 당 한 번 >
--  좋아요 관련 테이블도 새로 생성해야 할 것 같음
-- 한 계정 당 한 번의 좋아요인 경우~~~
-- 유저 아이디 + 앨범 아이디를 받아서 좋아요 추가
DELIMITER $$
CREATE OR REPLACE PROCEDURE member_add_album_like(
	IN uid BIGINT (20),
	IN a_id BIGINT (20)
)
BEGIN 
	IF NOT EXISTS (
		SELECT *
		FROM like_cnt
		WHERE member_id = uid AND album_id = a_id
	) 
	THEN
		INSERT INTO like_cnt(member_id, album_id) VALUES (uid, a_id);
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '이미 좋아요를 누른 곡입니다.';
	END IF;
END $$
DELIMITER ;

-- 좋아요 취소
-- 유저 아이디 + 앨범 아이디
DELIMITER $$
CREATE OR REPLACE PROCEDURE member_minus_album_like(
	IN uid BIGINT (20),
	IN a_id BIGINT (20)
)
BEGIN 
	IF EXISTS (
		SELECT *
		FROM like_cnt
		WHERE member_id = uid AND album_id = a_id
	) 
	THEN
		DELETE FROM like_cnt WHERE member_id = uid;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '좋아요를 누른 적 없습니다.';
	END IF;
END $$
DELIMITER ;




-- < 노래 제목으로 검색할 수 있다 >
-- 노래 이름 입력
-- 노래 이름 입력 시 노래 제목 / 장르 / 좋아요 수 / 재생 횟수 / 앨범 / 가수 출력
DELIMITER $$
CREATE OR REPLACE PROCEDURE search_song_title(
	IN song_title VARCHAR(30)
)
BEGIN
	SELECT s.NAME AS `노래 제목`,
			s.genre AS `장르`,
			s.Streaming_cnt AS `재생횟수`,
			a.`name` AS `앨범명`,
			m.`name` AS `가수명`
	FROM song AS s
	JOIN album AS a ON s.album_id = a.album_id
	JOIN member AS m ON a.member_id = m.member_id
	WHERE s.name LIKE CONCAT('%',song_title, '%')
	ORDER BY s.Streaming_cnt DESC;	
END$$
DELIMITER ;



-- < 가수 이름으로 검색할 수 있다 >
-- 가수 이름을 입력받아서 해당 이름을 갖는 member_id를 받음
-- 이 테이블과 song을 조인해서 노래 제목, 장르, 좋아요, 재생 횟수 출력
DELIMITER $$
CREATE OR REPLACE PROCEDURE search_singer_name(
	IN singer_name VARCHAR(20)
)
BEGIN

	SELECT s.NAME AS `노래 제목`,
			s.genre AS `장르`,
			s.Streaming_cnt AS `재생횟수`,
			a.`name` AS `앨범명`,
			m.`nickname` AS '가수명'
	FROM song AS s
	JOIN album AS a ON s.album_id = a.album_id
	JOIN member AS m ON a.member_id = m.member_id
	WHERE m.nickname = singer_name
	ORDER BY s.Streaming_cnt DESC;	
END$$
DELIMITER ;


-- < 장르 이름으로 노래 검색 > 
-- 노래 제목, 장르, 재생 횟수, 앨범명, 가수명까지
DELIMITER $$
CREATE OR REPLACE PROCEDURE search_genre(
	IN genre_name VARCHAR(10)
)
BEGIN
	SELECT s.NAME AS `노래 제목`,
			s.genre AS `장르`,
			s.Streaming_cnt AS `재생횟수`,
			a.`name` AS `앨범명`,
			m.`name` AS '가수명'
	FROM song AS s
	JOIN album AS a ON s.album_id = a.album_id
	JOIN member AS m ON a.member_id = m.member_id
	WHERE s.genre LIKE genre_name
	ORDER BY s.Streaming_cnt DESC;	

END$$
DELIMITER ;


-- < 좋아요 10만개 이상이면 명반 등극 >
-- 1년에 한 번씩 업데이트
-- 좋아요가 10만개 이상이면 명반(1)로 변경 / 
-- 좋아요가 10만개보다 적으면 명반  취소(0) 
DELIMITER $$
CREATE EVENT IF NOT EXISTS enroll_masterpiece
ON SCHEDULE EVERY 1 YEAR STARTS '2024-12-31 10:00:00' DO 
BEGIN
	UPDATE album
	SET FIELD = 1
	WHERE album_id IN (
			SELECT album_id
			FROM like_cnt
			GROUP BY album_id
			HAVING COUNT(*) >= 100000);
	UPDATE album
	SET FIELD = 0
	WHERE album_id IN (
			SELECT album_id
			FROM like_cnt
			GROUP BY album_id
			HAVING COUNT(*) < 100000);
END $$
DELIMITER ;


-- < 앨범 전체 노래를 플레이 리스트에 넣기 >
-- 앨범 아이디, 플레이리스트 아이디를 입력 받아서 추가하기
-- 플레이리스트는 전체 다 존재한다고 가정

-- 인덱싱 사용 시나리오까지 ->

DELIMITER $$
CREATE OR REPLACE PROCEDURE album_in_ply(
	IN a_id BIGINT(20),
	IN p_id BIGINT(20)
)
BEGIN
	INSERT INTO song_in_playlist(playList_id, song_id)
	SELECT p_id, song_id
	FROM song
	WHERE album_id = a_id;
	
END $$
DELIMITER ;


CREATE INDEX idx_song_id ON song(song_id);
EXPLAIN (
	SELECT *
	FROM song
	WHERE song_id = 118
);


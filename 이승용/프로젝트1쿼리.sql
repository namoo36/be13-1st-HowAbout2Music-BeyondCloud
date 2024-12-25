USE beyondcloud;

INSERT INTO member(PASSWORD,NAME, email, nickname) VALUES (1234, 'lee', 'sjeseg', 'namoo');
DELETE FROM member WHERE member_id = 1;
DELETE FROM playlist WHERE member_id = 1;



-- 개인 유저 별 플레이리스트 생성 프로시저

-- < 개인 회원 플레이리스트 생성 >
--  유저 아이디/ 플리 이름/공유유무만 받아서 새롭게 생성 
--  공유 유무에 NULL값(아무런 값을 받지 않는다고 가정)을 받을 경우 default 값으로 설정
--  최근 수정일은 디폴트 값(현재 시간)으로 정함.
--  이미 있는 회원이 아니면 외래키 이슈로 오류 발생함
DELIMITER $$
CREATE OR REPLACE PROCEDURE make_playlist(
	IN uid BIGINT(20), 
	IN play_list_name VARCHAR(20),
	IN is_shared TINYINT(1)
)

BEGIN 
	SET is_shared = IFNULL(is_shared, 0);
	INSERT INTO playlist(`name`, member_id, isPublic) 
	VALUES(play_list_name, uid, is_shared);
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
		WHERE s.plyaList_id = ply_id AND s.song_id = song_id
	) 
	THEN
		INSERT INTO song_in_playlist(plyaList_id, song_id) 
		VALUES(ply_id, song_id);
	ELSE 
		SELECT '이미 존재하는 곡입니다.';
	END IF;
END $$
DELIMITER ;


-- < 노래를 현재 재생 목록에 담을 수 있다 >
--  유저 아이디, 노래 아이디, 현재 시간, 노래 전체 플레이 시간 받기
--  유저가 노래를 시작하면 현재 재생 목록이 생성 + 현재 재생목록 아이디도 같이 생성

--  필요한 값 -> 노래 재생 시간 / 시작 시간도 필요,
SHOW VARIABLES LIKE 'event_scheduler';
SET GLOBAL event_scheduler = ON;


DELIMITER $$
CREATE OR REPLACE PROCEDURE del_song_cur_ply(
	IN now_pid BIGINT(20), 
	IN s_id BIGINT (20)
)
BEGIN
	DELETE FROM song_in_nowplaylist
	WHERE song_id = s_id;
	DELETE FROM nowplaylist
	WHERE nowPlayList_id = now_pid;
END $$
DELIMITER ; 


DELIMITER $$
CREATE OR REPLACE PROCEDURE add_song_current_ply(
	IN uid BIGINT (20),
	IN s_id BIGINT (20),
	IN p_time INT -- > 초단위로 입력받기
)
BEGIN
	DECLARE now_ply_id BIGINT(20);
	
	-- 유저가 현재 재생 목록을 가지고 있지 않은 경우
	IF NOT EXISTS(
		SELECT *
		FROM nowplaylist
		WHERE member_id = uid
		)
	THEN 
		-- 해당 유저의 현재 재생 목록을 새롭게 생성해줌
		INSERT INTO nowplaylist(member_id) VALUES (uid);
		
		-- 해당 유저가 생성한 현재 재생 목록의 아이디를 now_ply_id에 받음
		SELECT member_id INTO now_ply_id
		FROM nowplaylist
		WHERE member_id = uid;
		
		INSERT INTO song_in_nowplaylist(song_id, nowplayList_id) VALUES (s_id, now_ply_id);
		
	ELSE 
		-- 해당 유저가 생성한 현재 재생 목록의 아이디를 now_ply_id에 받음
		SELECT member_id INTO now_ply_id
		FROM nowplaylist
		WHERE member_id = uid;
		
		UPDATE song_in_nowplaylist
		SET song_id = s_id, time = NOW(), ply_time = p_time 
		WHERE member_id = uid;
	END IF;
	
	-- song의 재생 횟수 추가
	UPDATE song
	SET Streaming_cnt = Streaming_cnt + 1
	WHERE song_id = s_id; 
	
END $$
DELIMITER ;

CREATE EVENT IF NOT EXISTS del_song_from_curply
ON SCHEDULE AT DATE_ADD(NOW(), INTERVAL p_time SECOND)
	DO 
		DELETE FROM song_in_nowplaylist
		WHERE song_id = s_id;
		DELETE FROM nowplaylist
		WHERE nowPlayList_id = now_pid;
		-- recursion 발생 -> 질문하자 이건



-- < 아티스트 승인이 된 유저는 노래를 등록할 수 있다.(한 곡) > 
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
	DECLARE u_role VARCHAR(5);
	DECLARE new_album_id BIGINT(20);
	
	SELECT `role`INTO u_role
	FROM member
	WHERE member_id = uid;
	
	IF u_role LIKE 'Artist' THEN
			-- 앨범 먼저 등록
			INSERT INTO album(NAME, artist_name) 
			VALUES(a_name, (SELECT `name` FROM member WHERE member_id = uid));
			
			-- 가장 최근에 등록된 앨범의 아이디를 new_album_id에 저장
			SET new_album_id = LAST_INSERT_ID();
			
			-- 노래를 해당 앨범 아이디에 저장
			INSERT INTO song(`name`, genre, album_id) 
			VALUES(s_name, s_genre, new_album_id);
	ELSE 
			SELECT '일반 유저는 노래를 추가할 수 없습니다.';
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
	IN s_name TEXT,   -- > 노래 이름 받기(,  기준으로 받기)
	IN s_genre VARCHAR(10),
	IN a_name VARCHAR (50),
	IN s_time TEXT -- > 노래 시간 받기(, 기준으로 시간 맞춰서)
)
BEGIN 
	DECLARE u_role VARCHAR(5);
	DECLARE song_count INT;
	DECLARE song_title VARCHAR(30);
	DECLARE song_time INT;
	DECLARE new_album_id BIGINT(20);
	
	SELECT `role`INTO u_role
	FROM member
	WHERE member_id = uid;
	
	SET song_count = 1;
	
	IF u_role LIKE 'Artist' THEN
			-- 앨범 아이디 먼저 받기
			INSERT INTO album(NAME, artist_name) 
			VALUES(a_name, (SELECT `name` FROM member WHERE member_id = uid));
			
			SET new_album_id = LAST_INSERT_ID();
			
		-- , 기준으로 나눠진 텍스트로 받은 값을 나눠서 노래를 앨범에 저장
		WHILE song_count <= LENGTH(s_name) - LENGTH(REPLACE(s_name, ',', '')) + 1
		DO 
			SET song_title = TRIM(SUBSTRING_INDEX(s_name, ',',song_count));
			SET song_time = CAST(TRIM(SUBSTRING_INDEX(s_time, ',',song_count)) AS INT);
			
			INSERT INTO song(`name`, genre, album_id) 
			VALUES(song_title, s_genre, new_album_id);
			
			SET song_count = song_count + 1;
		END WHILE;
	ELSE 
			SELECT '일반 유저는 노래를 추가할 수 없습니다.';
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
	DECLARE u_role VARCHAR(5);     
	DECLARE song_u_id BIGINT (20);
	
	-- 해당 아이디의 유저가 아티스트인지 확인
	SELECT `role`INTO u_role
	FROM member
	WHERE member_id = uid;	
	
	IF u_role LIKE 'Artist' THEN
	
		-- 해당 유저가 저장한 노래의 u_id를 확인
		SELECT s.song_id INTO `song_u_id`
		FROM song AS s 
		JOIN album AS a ON s.album_id = a.album_id
		WHERE a.member_id = uid AND s.name = song_name;
		
		
		IF ISNULL(song_u_id) THEN 
			SELECT '해당 노래가 존재하지 않습니다.';
			
		ELSE 
			-- 노래가 존재할 경우 해당 노래를 삭제
			DELETE FROM song
			WHERE song_id = song_u_id;
			
			SELECT '노래가 제거되었습니다.';
			
		END IF;

	ELSE 
		SELECT '일반 유저는 노래를 삭제할 수 없습니다.';

	END IF;
END $$
DELIMITER ;


-- 2) 노래 수정 -> 업데이트(노래 제목, 장르, (시간?) )
DELIMITER $$

CREATE OR REPLACE PROCEDURE my_song_edit(
	IN uid BIGINT (20),
	IN edit_song_name VARCHAR (30),
	IN edit_song_genre VARCHAR (10)
)
BEGIN 
	DECLARE u_role VARCHAR(5);
	DECLARE song_u_id BIGINT (20);
	
	-- 해당 아이디의 유저가 아티스트인지 확인
	SELECT `role`INTO u_role
	FROM member
	WHERE member_id = uid;	
	
	IF u_role LIKE 'Artist' THEN
	
		-- 유저의 노래 제목에 맞는 아이디를 조회
		SELECT s.song_id INTO `song_u_id`
		FROM song AS s 
		JOIN album AS a ON s.album_id = a.album_id
		WHERE a.member_id = uid AND s.name = song_name;
		
		IF ISNULL(song_u_id) THEN SELECT '해당 노래가 존재하지 않습니다.';			
		ELSE 
			UPDATE song
			SET `name` = edit_song_name, genre = edit_song_genre
			WHERE song_id = song_u_id;	
		END IF;

	ELSE 
		SELECT '일반 유저는 노래를 삭제할 수 없습니다.';

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




-- < 노래에 대한 좋아요 남기기 가능- 계정 당 한 번 >
--  좋아요 관련 테이블도 새로 생성해야 할 것 같음
-- 한 계정 당 한 번의 좋아요인 경우~~~
-- 노래에 song_count를 넣는 형태가 아니라 특정 노래 당 유저 한 명의 좋아요 하나씩 넣는 방식으로

/*
CREATE TABLE song_like(
	like_id BIGINT(20),
	m_id BIGINT(20),
	s_id BIGINT(20),
	UNIQUE (m_id, s_id)    -- 한 유저 당 특정 노래에 대해 단 하나의 값만 가질 수 있도록
);
	
DELIMITER $$
CREATE OR REPLACE PROCEDURE member_add_song_like(
	IN uid BIGINT (20),
	IN s_id BIGINT (20)
)
BEGIN 
	IF NOT EXISTS (
		SELECT *
		FROM song_like
		WHERE member_id = m_id AND song_id = s_id;
	) 
	THEN
		INSERT INTO song_like(member_id, song_id) VALUES (m_id, s_id);
		UPDATE song SET good_cnt = good_cnt + 1 WHERE song_id = s_id;
	ELSE
		SELECT '이미 좋아요를 누른 곡입니다.';
	END IF;
END $$
DELIMITER ;
);

*/



-- < 노래 제목으로 검색할 수 있다 >
-- 노래 이름 입력, -> 동일한 이름의 노래를 몇 개까지 허용? 전체 출력?
-- 노래 이름 입력 시 노래 제목 / 장르 / 좋아요 수 / 재생 횟수 / 앨범 / 가수 출력

DELIMITER $$
CREATE OR REPLACE PROCEDURE search_song_title(
	IN song_title VARCHAR(30)
)
BEGIN
	SELECT s.NAME AS `노래 제목`,
			s.genre AS `장르`,
			s.good_cnt AS `좋아요 수`,
			s.Streaming_cnt AS `재생횟수`,
			a.`name` AS `앨범명`,
			a.artist_name AS `가수명`
	FROM song AS s
	LEFT OUTER JOIN album AS a ON s.album_id = a.album_id
	WHERE s.name LIKE song_title;	
END$$
DELIMITER ;



-- < 가수 이름으로 검색할 수 있다 >
-- 가수 이름을 입력받아서 해당 이름을 갖는 member_id를 distinct하게 받은 뒤,
-- 이 테이블과 song을 조인해서 노래 제목, 장르, 좋아요, 재생 횟수 출력
DELIMITER $$
CREATE OR REPLACE PROCEDURE search_singer_name(
	IN singer_name VARCHAR(20)
)
BEGIN
	SELECT s.NAME AS `노래 제목`,
			s.genre AS `장르`,
			s.good_cnt AS `좋아요 수`,
			s.Streaming_cnt AS `재생횟수`,
			a.`name` AS `앨범명`,
			a.artist_name AS `가수명`
	FROM song AS s
	JOIN album AS a ON s.album_id = a.album_id
	WHERE a.artist_name LIKE singer_name
	ORDER BY s.good_cnt, s.Streaming_cnt;	
END$$
DELIMITER ;


-- < 장르 이름으로 검색 > 
-- 노래 제목, 장르, 좋아요 수, 재생 횟수
-- 혹시 가수 제목, 앨범 이름이 필요할까? -> 통상적으로 다 필요하긴 하지... 

DELIMITER $$
CREATE OR REPLACE PROCEDURE search_genre(
	IN genre_name VARCHAR(10)
)
BEGIN
	SELECT s.NAME AS `노래 제목`,
			s.genre AS `장르`,
			s.good_cnt AS `좋아요 수`,
			s.Streaming_cnt AS `재생횟수`,
			a.`name` AS `앨범명`,
			a.artist_name AS `가수명`
	FROM song AS s
	JOIN album AS a ON s.album_id = a.album_id
	WHERE s.genre LIKE genre_name
	ORDER BY s.good_cnt, s.Streaming_cnt;	

END$$
DELIMITER ;



-- < 좋아요 10만개 이상이면 명반 등극 >
/*
CREATE TABLE masterpiece_song(
	song_id BIGINT(20),
	album_id BIGINT(20),
	good_cnt BIGINT(20)
);

DELIMITER $$
CREATE OR REPLACE TRIGGER enroll_masterpiece
AFTER INSERT ON song
FOR EACH ROW
BEGIN 
	IF new.good_cnt > 100000 THEN
		INSERT INTO masterpiece_song VALUES(new.song_id, new.album_id, new.good_cnt);
	END IF;
END $$
DELIMITER ; 
*/




-- < 앨범 전체 노래를 플레이 리스트에 넣기 >
-- 앨범 아이디, 플레이리스트 아이디를 입력 받아서 추가하기
-- 플레이리스트는 전체 다 존재한다고 가정

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
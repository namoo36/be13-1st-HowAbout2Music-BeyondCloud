USE beyondcloud;


-- 유저가 노래를 재생하는 과정 -> 
-- 1) nowPlaylist에 등록되어 있지 않은 유저였을 경우(현재 재생 목록이 없는 경우) 
--    - 새롭게 현재 재생 목록을 생성 
--    - 현재 재생중인 노래에 노래 아이디 추기, 현재 재생 목록에 담긴 노래에 추가
--    - 노래 아이디를 받아서 인터벌로 스케줄러 계산

-- 2) nowPlaylist에 이미 등록되어 있는 유저인 경우 
--    - 현재 재생목록에 담긴 노래에 노래 아이디, 현재 시간 추가 / 재생중인 노래에 노래 아이디 추가

-- 3) 다음 노래에 대한 쿼리 생성
--    - 랜덤으로 노래를 재생할지? 아니면 그냥 순차적으로 플레이할지?


DELIMITER $$
CREATE OR REPLACE PROCEDURE play_song_current_ply(
	IN uid BIGINT (20),
	IN s_id BIGINT (20)
)
BEGIN
	DECLARE now_ply_id BIGINT(20);
	DECLARE song_length INT;
	
	-- 유저가 현재 재생 목록을 가지고 있지 않은 경우
	IF NOT EXISTS(
		SELECT *
		FROM nowplaylist
		WHERE member_id = uid
		)
	THEN 
		-- 해당 유저의 현재 재생 목록을 새롭게 생성해줌
		INSERT INTO nowplaylist(member_id) VALUES (uid);
	END IF;
	
	-- 해당 유저가 생성한 현재 재생 목록의 아이디를 now_ply_id에 받음
	SELECT nowPlayList_id INTO now_ply_id
	FROM nowplaylist
	WHERE member_id = uid;
	
	
	-- 현재 재생목록에 담긴 노래가 이미 존재할 경우 삭제
	IF EXISTS(
		SELECT *
		FROM song_in_nowplaylist
		WHERE song_id = s_id AND nowplayList_id = now_ply_id	
	) THEN
		DELETE FROM song_in_nowplaylist WHERE song_id = s_id AND nowplayList_id = now_ply_id;
	END IF;
	
	-- 재생중인 노래 삭제
	DELETE FROM Listening_song WHERE nowplayList_id = now_ply_id;
	
	-- 해당 아이디의 노래의 길이를 song_length에 저장
	SELECT length INTO song_length
	FROM song
	WHERE song_id = s_id;
	
	-- 해당 노래를 재생중인 노래 / 현재 재생목록에 담긴 노래에 저장
	INSERT INTO song_in_nowplaylist(song_id, nowplayList_id) VALUES (s_id, now_ply_id);
	INSERT INTO Listening_song(Listening_song_id, nowplayList_id) VALUES (s_id, now_ply_id);
	INSERT INTO streaming_count_by_member(member_id, song_id) VALUES (uid, s_id);
	
	EXECUTE IMMEDIATE CONCAT('DROP EVENT IF EXISTS ', 'del_song');
	SET @event_sql = CONCAT(
        'CREATE EVENT del_song', 
        ' ON SCHEDULE AT "', DATE_ADD(NOW(), INTERVAL song_length SECOND), '" ',
        'DO BEGIN ',
        '   DELETE FROM Listening_song WHERE Listening_song_id = ', s_id, ' AND nowPlayList_id = ', now_ply_id, '; ',
		  '   DELETE FROM song_in_nowplaylist WHERE song_id = ', s_id, ' AND nowPlayList_id = ', now_ply_id, '; ',
        'END'
    );
	PREPARE stmt FROM @event_sql;
   EXECUTE stmt;
   DEALLOCATE PREPARE stmt;	
	
END $$
DELIMITER ;



-- 재생중인 노래 테이블에 노래가 업데이트되면 자동으로
-- 노래의 streaming_cnt가 1 증가되도록 하는 트리거 생성
DELIMITER $$
CREATE OR REPLACE TRIGGER song_streaming_cnt_increase
AFTER INSERT ON Listening_song
FOR EACH ROW
BEGIN 
	UPDATE song
	SET Streaming_cnt = Streaming_cnt + 1
	WHERE song_id = NEW.Listening_song_id;
	
END $$
DELIMITER ;



-- 다음 노래에 대한 프로시저 생성
-- 다음 노래를 찾는 것이기 때문에 현재 재생 목록에 해당 유저와 노래 아이디는 반드시 존재
-- 유저 아이디, 노래 아이디를 입력 -> 현재 재생목록에 담긴 노래로 다음 노래를 조회, return
-- return 값은 null이 될 수도 있음.

DELIMITER $$
CREATE OR REPLACE PROCEDURE next_cur_song(
	IN u_id BIGINT(20),
	IN s_id BIGINT(20)
)
BEGIN
DECLARE n_ply_id BIGINT(20);
DECLARE c_reg_date DATETIME;

	-- 입력으로 받은 회원 아이디로 현재 재생목록 아이디를 조회, n_ply_id에 저장
	SELECT nowPlayList_id INTO n_ply_id
	FROM nowplaylist
	WHERE member_id = u_id; 
	
	-- 조회한 플레이 리스트 아이디 및 노래 아이디로 reg_date 조회
	SELECT reg_date INTO c_reg_date
	FROM Song_in_nowplaylist
	WHERE nowPlayList_id = n_ply_id AND song_id = s_id;
	
	-- 날짜 순서대로 정렬되어 있는 노래들 중 제일 먼저 등록한 노래가 먼저 나오도록 
	SELECT song_id
	FROM Song_in_nowplaylist
	WHERE nowPlayList_id = n_ply_id AND reg_date > c_reg_date
	ORDER BY reg_date
	LIMIT 1;
	
END $$
DELIMITER ;


DELIMITER $$

CREATE TRIGGER after_song_del_from_listening_song
AFTER DELETE ON Listening_song
FOR EACH ROW
BEGIN
    DECLARE n_ply_id BIGINT(20);
    DECLARE c_reg_date DATETIME;
    DECLARE next_song_id BIGINT(20);

    -- 삭제된 노래에 대한 reg_date 조회
    SELECT reg_date INTO c_reg_date
    FROM song_in_nowplaylist
    WHERE nowPlayList_id = OLD.nowPlaylist_id AND song_id = OLD.Listening_song_id;

    -- 삭제된 노래 이후의 노래들 중에서 가장 먼저 등록된 노래를 찾음
    SELECT song_id INTO next_song_id
    FROM Song_in_nowplaylist
    WHERE nowPlayList_id = n_ply_id AND reg_date > c_reg_date
    ORDER BY reg_date
    LIMIT 1;

    -- 찾은 다음 노래를 Listening_song 테이블에 추가
    INSERT INTO Listening_song (song_id, nowPlayList_id) VALUES (next_song_id, n_ply_id);
END $$

DELIMITER ;

-- 현재 재생 목록에 노래 추가
-- 유저 아이디, 노래 아이디를 입력 받기
-- 이미 재생 목록에 노래가 있는 경우 탈락!
-- 현재 재생 목록이 없는 경우 재생 목록을 새롭게 생성하도록
DELIMITER $$
CREATE OR REPLACE PROCEDURE add_cur_song_ply(
	IN uid BIGINT (20),
	IN s_id BIGINT (20)
)
BEGIN
	DECLARE now_ply_id BIGINT(20);
	DECLARE song_length INT;
	
	-- 유저가 현재 재생 목록을 가지고 있지 않은 경우
	IF NOT EXISTS(
		SELECT *
		FROM nowplaylist
		WHERE member_id = uid
		)
	THEN 
		-- 해당 유저의 현재 재생 목록을 새롭게 생성해줌
		INSERT INTO nowplaylist(member_id) VALUES (uid);
	END IF;
	
	-- 해당 유저가 생성한 현재 재생 목록의 아이디를 now_ply_id에 받음
	SELECT nowPlayList_id INTO now_ply_id
	FROM nowplaylist
	WHERE member_id = uid;
	
	-- 현재 재생 목록에 해당 노래가 없는 경우 노래를 추가
	IF NOT EXISTS(
		SELECT *
		FROM song_in_nowplaylist
		WHERE song_id = s_id AND nowplayList_id = now_ply_id	
	) THEN
		INSERT INTO song_in_nowplaylist(song_id, nowplayList_id) VALUES (s_id, now_ply_id);
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 현재 재생 목록에 존재하는 노래입니다.';
	END IF;
	
END $$
DELIMITER ;


-- 현재 재생 목록에서 노래 삭제
-- 유저 아이디, 노래 아이디를 받아서 삭제
-- 만약 해당 노래가 존재하지 않은 경우 -> 삭제할 노래가 없습니다.
-- 유저 아이디의 현재 재생 목록이 없는 경우 -> 현재 재생 목록이 존재하지 않습니다.
-- 삭제가 제대로 된 경우 -> 삭제가 완료되었습니다. 

DELIMITER $$
CREATE OR REPLACE PROCEDURE del_cur_song_ply(
	IN uid BIGINT (20),
	IN s_id BIGINT (20)
)
BEGIN
	DECLARE now_ply_id BIGINT(20);
	DECLARE song_length INT;
	
	SELECT nowPlayList_id INTO now_ply_id
	FROM nowplaylist
	WHERE member_id = uid;
	
	-- 유저가 현재 재생 목록을 가지고 있지 않은 경우
	IF ISNULL(now_ply_id)THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '현재 재생 목록이 존재하지 않습니다.';
	ELSE 
		-- 만약 현재 재생 목록에 해당 노래가 존재하지 않는 경우
		IF NOT EXISTS(
			SELECT *
			FROM song_in_nowplaylist
			WHERE nowPlayList_id = now_ply_id AND song_id = s_id
		) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '현재 재생 목록에 해당 노래가 존재하지 않습니다.';
		ELSE 
		  DELETE FROM song_in_nowplaylist WHERE song_id = s_id AND nowPlayList_id = now_ply_id;
		END IF;
	END IF;

END $$
DELIMITER ;
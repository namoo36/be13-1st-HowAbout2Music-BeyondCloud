# be13-1st-2team



--------
## 프로시저 실행 결과🔑
### 노래🎤
#### 1. 플레이리스트
<details>
<summary>플레이 리스트 생성</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>

<details>
<summary>플레이 리스트에 노래 담기</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>

#### 2. 노래 등록/수정
<details>
<summary>아티스트 승인 유저 노래 등록 가능(한 곡)</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>


<details>
<summary>아티스트 승인 유저 노래 등록 가능(여러 곡)</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>


<details>
<summary>내가 올린 노래 삭제 가능</summary>
<div markdown="1">

```SQL
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
    			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  '해당 노래가 존재하지 않습니다.';
    			
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
```

</div>
</details>


<details>
<summary>내가 올린 노래 수정 가능</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>


#### 3. 댓글

<details>
<summary>노래 댓글 기능</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>

<details>
<summary>노래 댓글 삭제 기능</summary>
<div markdown="1">

```SQL
    DELIMITER $$
    CREATE OR REPLACE PROCEDURE user_comment_del(
    	IN uid BIGINT (20),
    	IN c_id BIGINT (20)
    )
    BEGIN 
    	DELETE FROM comment WHERE comment_id = c_id;
    END $$
    DELIMITER ;
```

</div>
</details>

#### 4. 현재 재생 목록

<details>
<summary>현재 재생 목록 추가</summary>
<div markdown="1">

```sql
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
```

</div>
</details>


<details>
<summary>현재 재생 목록에 노래 추가</summary>
<div markdown="1">

```sql
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
```

</div>
</details>


<details>
<summary>현재 재생 목록에서 노래 삭제</summary>
<div markdown="1">

```sql
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
```

</div>
</details>



<details>
<summary>재생 중인 노래 재생 횟수 증가</summary>
<div markdown="1">

```sql
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
```

</div>
</details>

<details>
<summary>다음 재생 노래</summary>
<div markdown="1">

```sql
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
    	WHERE nowPlayList_id = n_ply_id AND reg_date < c_reg_date
    	ORDER BY reg_date
    	LIMIT 1;
    	
    END $$
    DELIMITER ;
```

</div>
</details>


&nbsp;
### 검색🔎
<details>
<summary>노래 제목 검색</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>

<details>
<summary>노래 가수 검색</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>

<details>
<summary>노래 장르 검색</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>

&nbsp;
### 앨범🧑‍🎤

<details>
<summary>앨범 좋아요 누르기 기능</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>

<details>
<summary>앨범 좋아요 취소 기능</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>

<details>
<summary>좋아요 10만개 이상일 경우 명반 등록</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>


<details>
<summary>앨범 전체 노래 플리 등극 가능</summary>
<div markdown="1">

```SQL
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
```

</div>
</details>


--------------


-- 공유를 허용해 둔 플리 조회 / 복사
-- 1) 조회
DELIMITER $$
CREATE OR REPLACE PROCEDURE playlist_public_r()
BEGIN
    SELECT `name`,
	 			reg_date
    FROM playlist 
    WHERE isPublic = 1;

END $$
DELIMITER ;

CALL playlist_public_r();


-- 2)복사
DELIMITER $$

CREATE OR REPLACE PROCEDURE playlist_copy(
	    IN original_mem_id BIGINT(20),  -- 원본 플레이리스트의 사용자 ID
	    IN pl_name VARCHAR(50),        -- 원본 플레이리스트의 제목
	    IN copy_mem_id BIGINT(20)      -- 복사할 플레이리스트를 받을 사용자 ID
)
BEGIN
    -- 새로 생성된 플레이리스트 ID 담을 변수 선언
    DECLARE new_playlist_id BIGINT;

    -- playlist 테이블 복사
    INSERT INTO playlist(`name`, isPublic, member_id)
        SELECT `name`, 
            isPublic, 
            copy_mem_id 
        FROM playlist
        WHERE member_id = original_mem_id 
			AND `name` = pl_name;

    -- 새로 생성된 플레이리스트 ID 할당
    SET new_playlist_id = (SELECT playlist_ID 
                           FROM playlist
                           WHERE member_id = copy_mem_id 
									AND `name` = pl_name);
        INSERT INTO song_in_playlist (playlist_id, song_id)
        SELECT new_playlist_id,
               song_id
        FROM song_in_playlist i
        INNER JOIN playlist p
        ON i.playList_id = p.playList_id
        WHERE member_id = original_mem_id
        AND `name` = pl_name;

    SELECT 
        p.`name` AS playlist_name,
        s.`name` AS song_name,
        s.genre,
        s.length
    FROM playlist p
   INNER JOIN song_in_playlist i
   ON p.playList_id = i.playList_id
   INNER JOIN song s
   ON s.song_id = i.song_id
    WHERE p.`name` = pl_name
        AND p.member_id = copy_mem_id;

END $$

DELIMITER ;

CALL playlist_copy(450, 'cafe', 526);
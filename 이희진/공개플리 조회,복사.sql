-- 공유를 허용해 둔 플리 조회 / 복사
-- 1) 조회
DELIMITER $$
CREATE OR REPLACE PROCEDURE playlist_public_r()
BEGIN
    SELECT *
    FROM playlist 
    WHERE isPublic = 1;

END $$
DELIMITER ;

CALL playlist_public_r();


-- 2)복사
DELIMITER $$
CREATE OR REPLACE PROCEDURE playlist_copy(
    IN mem_id BIGINT(20)
)
BEGIN
    INSERT INTO playlist (name, isPublic, member_id)
        SELECT name, isPublic, mem_id
        FROM playlist 
        WHERE isPublic = 1
        LIMIT 1;

    SELECT * 
    FROM playlist
    WHERE member_id = mem_id;
END $$
DELIMITER ;

CALL playlist_copy(450);


-- call 하면 mem_id 까지 끌어와서 수정해 본거

DELIMITER $$

CREATE OR REPLACE PROCEDURE playlist_copy(
    IN original_mem_id BIGINT(20),  -- 원본 플레이리스트의 사용자 ID
    IN copy_mem_id BIGINT(20)       -- 복사할 플레이리스트를 받을 사용자 ID
)
BEGIN

    INSERT INTO playlist (name, isPublic, member_id)
        SELECT name, isPublic, copy_mem_id 
        FROM playlist 
        WHERE isPublic = 1
        AND member_id = original_mem_id 
        LIMIT 1; 

    SELECT * 
    FROM playlist
    WHERE member_id = copy_mem_id; 
END $$

DELIMITER ;

CALL playlist_copy(450, 526);


-- title (name) 으로 검색해서 복사
DELIMITER $$

CREATE OR REPLACE PROCEDURE playlist_copy_by_title(
    IN copy_mem_id BIGINT(20),      -- 복사할 플레이리스트를 받을 사용자 ID
    IN playlist_name VARCHAR(50)    -- 복사할 플레이리스트의 타이틀 (이름)
)
BEGIN

    INSERT INTO playlist (name, isPublic, member_id)
        SELECT name, isPublic, copy_mem_id  
        FROM playlist 
        WHERE isPublic = 1 
        AND name = playlist_name  
        LIMIT 1; 

    SELECT * 
    FROM playlist
    WHERE member_id = copy_mem_id;
END $$

DELIMITER ;

CALL playlist_copy_by_title(526, 'cafe');
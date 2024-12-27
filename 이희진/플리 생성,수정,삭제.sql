-- 나의 플레이 리스트들 관리
-- 플레이 리스트를 생성 / 수정 / 삭제 가능
-- 1) 플리 생성
DELIMITER $$

CREATE OR REPLACE PROCEDURE playlist_c(
    IN plName VARCHAR(50),
    IN Public TINYINT,
    IN mem_id BIGINT(20)
)
BEGIN
   
    IF Public NOT IN (0, 1) THEN
        SET Public = 0;
    END IF;

    SET Public = IFNULL(Public, 0);

    INSERT INTO playlist (name, isPublic, member_id)
    VALUES (plName, Public, mem_id);

    SELECT *
    FROM playlist
    WHERE member_id = mem_id;
END $$

DELIMITER ;

CALL playlist_c('cafe', 1, 450);


-- 2) 수정
DELIMITER $$

CREATE OR REPLACE PROCEDURE playlist_u(
    IN plName VARCHAR(50),
    IN change_name VARCHAR(50),
    IN Public TINYINT,
    IN mem_id BIGINT(20)
)
BEGIN

    IF Public NOT IN (0, 1) THEN
        SET Public = 0;
    END IF;

    UPDATE playlist
    SET name = change_name,
        isPublic = Public
    WHERE name = plName
        AND member_id = mem_id;

    SELECT *
    FROM playlist
    WHERE name = change_name AND member_id = mem_id;

END $$

DELIMITER ;


CALL playlist_u('drive', 'exercise', 1, 526);


-- 3) 삭제
DELIMITER $$

CREATE or REPLACE PROCEDURE playlist_d(
    IN plName VARCHAR(50), 
    IN mem_id BIGINT(20)
)
BEGIN

    DECLARE deleted_count INT;

    DELETE FROM playlist
    WHERE name = plName
        AND member_id = mem_id;

    SET deleted_count = ROW_COUNT();

    IF deleted_count > 0 THEN
        SELECT '삭제가 완료되었습니다.' AS message;
        SELECT * 
        FROM playlist
        WHERE name = plName AND member_id = mem_id;
    ELSE
        SELECT '해당 플레이리스트가 존재하지 않습니다.' AS message;
    END IF;

END $$

DELIMITER ;


CALL playlist_d('exercise', 526);

-- 이 음악 어때? 랜덤으로 플리 가져오기
DELIMITER $$

CREATE OR REPLACE PROCEDURE playlist_rand(
    IN mem_id BIGINT(20)
)
BEGIN

    INSERT INTO playlist (name, isPublic, member_id)
        SELECT name, isPublic, mem_id
        FROM playlist
        WHERE isPublic = 1
        AND member_id != mem_id
        AND name NOT IN (SELECT name FROM playlist WHERE member_id = mem_id)
        ORDER BY RAND()
        LIMIT 1;

    SELECT * 
    FROM playlist
    WHERE member_id = mem_id;

END $$

DELIMITER ;

CALL playlist_rand(413);
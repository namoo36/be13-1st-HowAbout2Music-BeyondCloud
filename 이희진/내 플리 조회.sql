-- 나의 플레이 리스트들 조회
-- 내가 만든 플레이 리스트들의 제목을 조회
DELIMITER $$
CREATE or REPLACE PROCEDURE playlist_title_r(
    IN mem_id BIGINT(20)
)
BEGIN
    SELECT name
    FROM playlist 
    WHERE member_id = mem_id;
END $$
DELIMITER ;

CALL playlist_title_r(450);


-- 내가 만든 플레이리스트의 내용을 조회
DELIMITER $$
CREATE OR REPLACE PROCEDURE playlist_r(
    IN mem_id BIGINT(20)
)
BEGIN
    SELECT *
    FROM playlist 
    WHERE member_id = mem_id;
END $$
DELIMITER ;

CALL playlist_r(450);

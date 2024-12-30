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


-- 내가 만든 플레이리스트의 노래목록 조회
DELIMITER $$

CREATE OR REPLACE PROCEDURE playlist_song_r(
     IN pl_name VARCHAR(50),
    IN mem_id BIGINT(20)
)
BEGIN
    SELECT 
        p.name AS playlist_name,
        s.name AS song_name,
        s.genre,
        s.length
    FROM playlist p
   INNER JOIN song_in_playlist i
   ON p.playList_id = i.playList_id
   INNER JOIN song s
   ON s.song_id = i.song_id
    WHERE p.name = pl_name
        AND p.member_id = mem_id;

END $$

DELIMITER ;

CALL playlist_song_r('cafe',450);
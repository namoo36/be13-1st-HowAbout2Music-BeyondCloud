-- 이 음악 어때? 랜덤으로 플리 가져오기
DELIMITER $$

CREATE OR REPLACE PROCEDURE playlist_rand(
    IN mem_id BIGINT(20)
)
BEGIN
    -- 랜덤으로 복사할 플레이 리스트 ID, 이름  담을 변수 선언
    DECLARE copy_playlist_id BIGINT;
    DECLARE copy_playlist_name VARCHAR(50);

    -- 새로 생성된 플레이리스트 ID 담을 변수 선언
   DECLARE new_playlist_id BIGINT;

    -- 랜덤으로 복사할 플레이 리스트 ID, 이름 담을 변수에 데이터 할당
   SELECT playlist_id, name
   INTO copy_playlist_id, copy_playlist_name
    FROM playlist
    WHERE isPublic = 1
    AND member_id != mem_id
    AND name NOT IN (SELECT name FROM playlist WHERE member_id = mem_id)
    ORDER BY RAND()
    LIMIT 1;


    -- playlist 테이블 Insert
    INSERT INTO playlist (name, isPublic, member_id)
        SELECT name, isPublic, mem_id
        FROM playlist
        WHERE playlist_id = copy_playlist_id;

   -- 새로 생성된 플레이리스트 ID 담을 변수에 데이터 할당
    SET new_playlist_id = (
                SELECT playlist_id
                FROM playlist
                WHERE member_id = mem_id 
                AND name = copy_playlist_name
                );


    -- song_in_playlist 테이블 Insert
    INSERT INTO song_in_playlist (playlist_id, song_id)
        SELECT new_playlist_id, song_id
        FROM song_in_playlist s
        WHERE playlist_id = copy_playlist_id;

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
    WHERE p.playList_id = new_playlist_id;

END $$

DELIMITER ;

CALL playlist_rand(413);
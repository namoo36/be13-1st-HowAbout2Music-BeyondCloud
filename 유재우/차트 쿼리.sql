-- 연도별 차트 추가
INSERT INTO Chart (`name`) VALUES 
	('2020`s'), ('2010`s'), ('2000`s')
;

-- 장르별 차트 추가
INSERT INTO chart (`name`) VALUES 
    ('인디'), ('랩'), ('K-POP'), ('발라드'), ('트로트')
;

INSERT INTO chart (`name`) VALUES ('신곡');

-- 하루가 지나면 실행되는 테이블 삭제 프로시저
DELIMITER $$

CREATE OR REPLACE PROCEDURE Refresh_Chart()
BEGIN
	TRUNCATE TABLE song_In_Chart;
END $$

DELIMITER ;

-- DB가 처음 시작할 때 한번만 실행
CALL Refresh_Chart();

-- 연대 별 모든 차트를 Song_In_Chart 테이블에 추가
DELIMITER $$

CREATE OR REPLACE PROCEDURE Insert_All_In_Chart(
    IN p_2000s_Chart_Id BIGINT,
    IN p_2010s_Chart_Id BIGINT,
    IN p_2020s_Chart_Id BIGINT
)
BEGIN
    -- song_in_chart에 데이터 삽입
    INSERT INTO Song_In_Chart (chart_id, song_id)
    SELECT 
        CASE
            WHEN a.rel_date >= '2020-01-01' THEN p_2020s_Chart_Id
            WHEN a.rel_date >= '2010-01-01' THEN p_2010s_Chart_Id
            WHEN a.rel_date >= '2000-01-01' THEN p_2000s_Chart_Id
            ELSE NULL
        END AS chart_id,
        s.song_id
    FROM 
        Song s
    INNER JOIN Album a ON s.album_id = a.album_id
    ORDER BY s.Streaming_cnt DESC
    LIMIT 100;

    -- 필요하면 결과 출력
    SELECT chart_id FROM Chart;
END $$

DELIMITER ;
-- CALL Insert_All_In_Chart(1, 2, 3);
-- CALL Get_Chart('2000`s');

-- 장르 별 노래를 차트에 삽입
DELIMITER $$

CREATE OR REPLACE PROCEDURE Insert_genre_in_chart(
    IN input_chart_name VARCHAR(10)
)
BEGIN
    DECLARE output_chart_id BIGINT(20);

    -- chart_name으로 chart_id 조회
    SELECT `chart_id` INTO output_chart_id
    FROM Chart
    WHERE `name` = input_chart_name;

    -- 동일한 chart_id를 가진 기존 데이터 삭제
    DELETE FROM Song_In_Chart
    WHERE chart_id = output_chart_id;

    -- song_in_chart에 데이터 삽입
    INSERT INTO Song_In_Chart (chart_id, song_id)
    SELECT 
        output_chart_id, 
        s.song_id
    FROM 
        Song s    
    WHERE s.genre = input_chart_name
    ORDER BY s.Streaming_cnt DESC										-- 스트리밍 횟수 내림차순 정렬
	 LIMIT 100;
END $$

DELIMITER ;

-- CALL Insert_genre_in_chart('인디');
-- CALL Get_Chart('인디');

-- 차트를 조회하는 프로시저
DELIMITER $$

CREATE OR REPLACE PROCEDURE Get_Chart (
	IN chart_name VARCHAR(20)
)
BEGIN
	SELECT RANK() OVER(ORDER BY s.Streaming_cnt DESC) AS '순위', 
		s.`name` AS '곡 제목',
		m.nickname AS '가수',
		s.genre AS '장르',
		s.album_id AS '앨범',
		s.Streaming_cnt AS '재생 횟수',
		s.`length` AS '곡 길이',
		a.rel_date AS '발매일'
	FROM Song_in_Chart sic
	RIGHT OUTER JOIN Song s ON sic.song_id = s.song_id
	LEFT OUTER JOIN Chart c ON sic.chart_id = c.chart_id
	LEFT OUTER JOIN album a ON a.album_id = s.album_id
	LEFT OUTER JOIN member m ON m.member_id = a.member_id
	WHERE c.`name` LIKE chart_name
	ORDER BY Streaming_cnt DESC
	LIMIT 100;
END$$

DELIMITER ;

-- CALL Get_Chart('2020`s');
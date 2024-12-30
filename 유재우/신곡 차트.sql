-- 이번 달에 나온 신곡의 차트를 생성 및 조회
DELIMITER $$

CREATE OR REPLACE PROCEDURE Insert_release_in_chart()
BEGIN
    DECLARE output_chart_id BIGINT(20);

    -- 신곡의 chart_id가 변경될 수 있으므로 chart_name으로 chart_id 조회 
    SELECT `chart_id` INTO output_chart_id
    FROM Chart
    WHERE `name` = '신곡';
    
    SELECT output_chart_id; -- chart_id가 맞게 선정 되었는 지 확인

    -- song_in_chart에 데이터 삽입
    INSERT INTO Song_In_Chart (chart_id, song_id)
    SELECT 
        output_chart_id, 
        s.song_id
    FROM 
        Song s
    INNER JOIN Album a ON s.album_id = a.album_id
    WHERE YEAR(a.rel_date) = YEAR(CURDATE())
  			 AND MONTH(a.rel_date) = MONTH(CURDATE())
  			 AND NOT EXISTS (
              SELECT 1 
              FROM Song_In_Chart sic 
              WHERE sic.chart_id = output_chart_id 
                AND sic.song_id = s.song_id
          ) -- 중복 song_id 방지 조건
    ORDER BY a.rel_date DESC										-- 스트리밍 횟수 내림차순 정렬
	 LIMIT 100;
END $$

DELIMITER ;

-- 이번 달에 발매된 신곡을 날짜 기준으로 조회하는 기능
DELIMITER $$

CREATE OR REPLACE PROCEDURE Get_Release_Song()
BEGIN
	SELECT s.`name` AS '곡 제목',
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
	WHERE c.`name` LIKE '신곡'
	ORDER BY a.rel_date DESC;
END$$

DELIMITER ;

-- 신곡 차트 삽입
-- CALL Insert_release_in_chart();

-- 신곡 차트 조회
-- CALL Get_Release_Song();
-- chart_id와 song_id들을 이용해서 song_in_chart에 INSERT
-- 차트안에 노래가 있으면 지우고 다시 삽입 구현해야 함
-- call Insert_years_in_chart('2024');
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
    ORDER BY s.Streaming_cnt DESC										-- 스트리밍 횟수 내림차순 정렬
	 LIMIT 100;
END $$

DELIMITER ;

-- 신곡 차트 삽입
-- CALL Insert_release_in_chart();

-- 신곡 차트 조회
-- CALL Get_Chart('신곡');
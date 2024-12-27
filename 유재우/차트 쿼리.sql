-- chart_id와 song_id들을 이용해서 song_in_chart에 INSERT
-- 차트안에 노래가 있으면 지우고 다시 삽입 구현해야 함
-- call Insert_years_in_chart('2024');
DELIMITER $$

CREATE OR REPLACE PROCEDURE Insert_years_in_chart(
    IN input_chart_name VARCHAR(10)
)
BEGIN
    DECLARE output_chart_id BIGINT(20);

    -- chart_name으로 chart_id 조회
    SELECT `chart_id` INTO output_chart_id
    FROM Chart
    WHERE `name` = input_chart_name;
    
    SELECT output_chart_id;

    -- song_in_chart에 데이터 삽입
    INSERT INTO Song_In_Chart (chart_id, song_id)
    SELECT 
        output_chart_id, 
        s.song_id
    FROM 
        Song s
    INNER JOIN Album a ON s.album_id = a.album_id
    WHERE YEAR(a.rel_date) = CAST(input_chart_name AS UNSIGNED)
    ORDER BY s.Streaming_cnt DESC										-- 스트리밍 횟수 내림차순 정렬
	 LIMIT 100;
END $$

DELIMITER ;


CALL Insert_years_in_chart('2024');
-- 차트를 부르는 프로시저
-- char_name: 차트 이름을 뜻 하는 매개변수
DELIMITER $$

CREATE OR REPLACE PROCEDURE Get_Chart (
	IN chart_name VARCHAR(20)
)
BEGIN
	SELECT ROW_NUMBER() OVER(ORDER BY s.Streaming_cnt DESC) AS '순위', 
		s.`name` AS '곡 제목',
		s.genre AS '장르',
		s.album_id AS '앨범',
		s.Streaming_cnt AS '재생 횟수',
		s.`length` AS '곡 길이'
	FROM Song_IStreaming_count_by_membern_Chart sic
	RIGHT OUTER JOIN Song s ON sic.song_id = s.song_id
	LEFT OUTER JOIN Chart c ON sic.chart_id = c.chart_id
	WHERE c.`name` LIKE chart_name
	ORDER BY Streaming_cnt DESC
	LIMIT 100;
END$$

DELIMITER ;

CALL Get_Chart('2024');
-- chart_id와 song_id들을 이용해서 song_in_chart에 INSERT
-- call Insert_years_in_chart('2024');
-- 2024년도에 발매된 노래 중에 재생횟수가 높은 순으로 내림차순한 song_id 추출
DELIMITER $$

CREATE OR REPLACE PROCEDURE Insert_years_in_chart(
    IN chart_name VARCHAR(10)
)
BEGIN
    DECLARE chart_id BIGINT;

    -- chart_name으로 chart_id 조회
    SELECT chart_id INTO chart_id
    FROM chart
    WHERE name = chart_name;

    -- song_in_chart에 데이터 삽입
    INSERT INTO song_in_chart (chart_id, song_id)
    SELECT 
        chart_id, 
        s.song_id
    FROM 
        song s
    INNER JOIN album a ON s.album_id = a.album_id
    WHERE s.release_date = chart_name AND a.name = chart_name
    ORDER BY s.Streaming_cnt DESC										-- 스트리밍 횟수 내림차순 정렬
	 LIMIT 100;
END $$

DELIMITER ;

-- 차트를 부르는 프로시저
-- char_name: 차트 이름을 뜻 하는 매개변수
-- ex) chart_name -> 신곡차트
DELIMITER $$

CREATE OR REPLACE PROCEDURE Get_chart (
	IN chart_name VARCHAR(20)
)
BEGIN
	SELECT *
	FROM song_in_chart s
	LEFT OUTER JOIN chart c ON s.chart_id = c.chart_id
	WHERE s.`name` LIKE chart_name
	ORDER BY Streaming_cnt DESC
	LIMIT 100;
END$$

DELIMITER ;
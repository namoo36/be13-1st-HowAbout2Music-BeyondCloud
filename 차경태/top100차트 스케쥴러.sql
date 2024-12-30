-- top100 차트
-- 관리자는 매일 자정에 각 노래별 전날 스트리밍 횟수로 top100차트를 집계한다.
-- straming_count_by 테이블에 각 노래별 재생횟수를 집계한다.
-- 00시마다 이 쿼리를 실행한다.


-- 이벤트 스케줄러가 활성화되어 있는지 확인
SELECT @@event_scheduler;
-- 이벤트 스케줄러 활성화
SET GLOBAL event_scheduler = ON;
-- 이벤트 확인
SHOW EVENTS;


-- 차트 집계 확인용



DELIMITER $$

CREATE or replace EVENT updateTop100chart
ON SCHEDULE EVERY 1 DAY 												-- 이벤트가 매일 반복되도록 설정
STARTS CURRENT_DATE
DO
BEGIN
   DECLARE top100_chart_id BIGINT;
	-- top100 차트 아이디 조회
	SELECT chart_id INTO top100_chart_id
	FROM Chart
	WHERE Chart.name = 'top100';
	
	-- 중복되지 않은 song_id 삽입
    INSERT INTO Song_In_Chart (chart_id, song_id)
    SELECT top100_chart_id, song_id
    FROM (
        SELECT song_id, ROW_NUMBER() OVER (PARTITION BY song_id ORDER BY song_id) AS rn
        FROM Streaming_count_by_member
    ) AS deduplicated
    WHERE rn = 1 -- song_id 기준 첫 번째만 삽입
    AND song_id NOT IN (
        SELECT song_id
        FROM Song_In_Chart
        WHERE chart_id = top100_chart_id
    );
END$$

DELIMITER ;

-- 이벤트 확인
SHOW EVENTS;



-- 확인용
DELIMITER $$
CREATE OR REPLACE PROCEDURE Insert_Top100_Chart ()
BEGIN
	DECLARE top100_chart_id BIGINT;
	-- top100 차트 아이디 조회
	SELECT chart_id INTO top100_chart_id
	FROM Chart
	WHERE Chart.name = 'top100';
	
	-- 중복되지 않은 song_id 삽입
    INSERT INTO Song_In_Chart (chart_id, song_id)
    SELECT top100_chart_id, song_id
    FROM (
        SELECT song_id, ROW_NUMBER() OVER (PARTITION BY song_id ORDER BY song_id) AS rn
        FROM Streaming_count_by_member
    ) AS deduplicated
    WHERE rn = 1 -- song_id 기준 첫 번째만 삽입
    AND song_id NOT IN (
        SELECT song_id
        FROM Song_In_Chart
        WHERE chart_id = top100_chart_id
    );
	
END$$
DELIMITER ;

CALL Insert_Top100_Chart;


-- 차트 조회
SELECT RANK() over(order by ifnull(tbl1.streaming_cnt,0) DESC ) AS '순위' ,s.name, m.nickname AS '가수명', ifnull(tbl1.streaming_cnt,0) AS 재생횟수
FROM (
	SELECT song_id, IFNULL(COUNT(*),0) AS `streaming_cnt`
	FROM Streaming_count_by_member
	GROUP BY song_id
) AS `tbl1`
join Song_In_Chart AS sic ON sic.song_id = tbl1.song_id
JOIN Chart AS c ON c.chart_id = sic.chart_id
JOIN Song AS s ON s.song_id = sic.song_id
JOIN Album AS a ON a.album_id = s.album_id
JOIN Member AS m ON m.member_id = a.member_id;

-- top100 차트
-- 관리자는 매일 자정에 각 노래별 전날 스트리밍 횟수로 top100차트를 집계한다.
-- straming_count_by 테이블에 각 노래별 재생횟수를 집계한다.
-- 00시마다 이 쿼리를 실행한다.


-- 이벤트 스케줄러가 활성화되어 있는지 확인
SELECT @@event_scheduler;
-- 이벤트 스케줄러 활성화
SET GLOBAL event_scheduler = ON;

DELIMITER $$

CREATE EVENT updateTop100chart
ON SCHEDULE EVERY 1 DAY 												-- 이벤트가 매일 반복되도록 설정
STARTS CURRENT_DATE
DO
BEGIN
   SELECT RANK() OVER(ORDER BY tbl1.streaming_cnt DESC) AS '순위', s.name, ifnull(tbl1.streaming_cnt,0) AS '재생횟수'
	FROM (
		SELECT song_id, IFNULL(COUNT(*),0) AS `streaming_cnt`
		FROM streaming_count_by_member
		GROUP BY song_id
		) AS `tbl1`
	right outer JOIN song AS `s` ON s.song_id = tbl1.song_id
END$$

DELIMITER ;

-- 이벤트 확인
SHOW EVENTS;


-- 차트 집계 확인용
SELECT RANK() OVER(ORDER BY tbl1.streaming_cnt DESC) AS '순위', s.name, ifnull(tbl1.streaming_cnt,0) AS '재생횟수'
FROM (
	SELECT song_id, IFNULL(COUNT(*),0) AS `streaming_cnt`
	FROM streaming_count_by_member
	GROUP BY song_id
) AS `tbl1`
right outer JOIN song AS `s` ON s.song_id = tbl1.song_id


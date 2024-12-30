-- 이벤트 스케줄러가 활성화되어 있는지 확인
SELECT @@event_scheduler;
-- 이벤트 스케줄러 활성화
SET GLOBAL event_scheduler = ON;

-- 하루가 지나면 실행되는 테이블 삭제 프로시저
DELIMITER $$

CREATE EVENT delete_Song_In_Chart_data_at_midnight
ON SCHEDULE EVERY 1 DAY 
STARTS CURRENT_DATE
DO
BEGIN
	TRUNCATE TABLE Song_In_Chart;
END $$

DELIMITER ;

-- 하루가 지나면 streaming_count_by_member에 있는 모든 데이터가 사라진다
DELIMITER $$

CREATE EVENT delete_streaming_count_by_member_data_at_midnight
ON SCHEDULE EVERY 1 DAY 												-- 이벤트가 매일 반복되도록 설정
STARTS CURRENT_DATE
DO
BEGIN
    TRUNCATE TABLE streaming_count_by_member;
END$$

DELIMITER ;

-- 이벤트 확인
SHOW EVENTS;
#탑100 차트의 로그를 기록할 테이블
drop table if exists chart_top100;
create table if not exists chart_top100(
	ranking int,
	name varchar(50),
	cnt int,
	exectime date default curdate()
);


#1단계 - 이벤트 스케줄러 상태 활성화
show variables like '%event_scheduler%';-- 출력값이 OFF라면 스케줄러가 비활성화 상태
select @@event_scheduler;
set global event_scheduler = on;


#2단계 - 매일 탑100 차트 (Streaming_count_by_member 테이블의 row 개수가 기준)
drop event if exists evt_scheduler_chart100;
delimiter $$
create or replace event evt_scheduler_chart100
on schedule every 1 minute
starts now() -- concat(curdate()," 00:00:00")
do
begin
	delete from chart_top100;-- 이전 기록 삭제

	insert into chart_top100 (ranking, name, cnt) 
	(select ROW_NUMBER() OVER (ORDER BY s.name), s.name 노래명, count(*) 재생횟수
	from Streaming_count_by_member scbm
	inner join Song s on scbm.song_id = s.song_id 
	group by scbm.song_id
	order by 3 desc
	limit 0,100);
end $$
delimiter ;

select * from chart_top100;



#장르에 대한 탑100 차트의 로그를 기록할 테이블
drop table if exists chart_genre_top100;
create table if not exists chart_genre_top100(
	ranking int,
	name varchar(50),
	cnt int,
	exectime date default curdate()
);

#3단계 - 장르에 대한 탑100 차트 (Song 테이블의 재생횟수 Streaming_cnt 컬럼값 기준)
drop event if exists evt_scheduler_genre100;   
delimiter $$
create or replace event evt_scheduler_genre100
on schedule every 1 minute
starts now() -- concat(curdate()," 00:00:00")
do
begin
	delete from chart_genre_top100;-- 이전 기록 삭제

	insert into chart_genre_top100 (ranking, name, cnt) 
	(select ROW_NUMBER() OVER (ORDER BY name), name 노래명, sum(Streaming_cnt) 재생횟수	from Song 
	group by genre
	order by 3 desc
	limit 0,100);
end $$
delimiter ;   


#4단계 - 이벤트 생성 확인
show events;
select * from information_schema.events;
SELECT * FROM information_schema.EVENTS WHERE EVENT_SCHEMA = 'how2music';


select * from chart_genre_top100;


-- 테스트를 위한 더미데이터
select database();

insert into Streaming_count_by_member values 
(1, 371, 301, now()),
(2, 371, 302, now()),
(3, 371, 303, now()),
(4, 371, 302, now()),
(5, 371, 301, now()),
(6, 371, 302, now()),
(7, 371, 301, now()),
(8, 371, 302, now()),
(9, 371, 301, now()),
(10, 371, 302, now()),
(11, 372, 303, now()),
(12, 372, 302, now()),
(13, 372, 302, now()),
(14, 372, 303, now()),
(15, 372, 302, now()),
(16, 372, 302, now()),
(17, 372, 301, now()),
(18, 372, 302, now()),
(19, 372, 301, now()),
(20, 372, 302, now()),
(21, 373, 301, now()),
(22, 373, 303, now()),
(23, 373, 301, now()),
(24, 373, 302, now()),
(25, 373, 301, now()),
(26, 373, 303, now()),
(27, 373, 301, now()),
(28, 373, 302, now()),
(29, 373, 301, now()),
(30, 373, 302, now()),
(31, 373, 301, now()),
(32, 373, 302, now());

select * from Streaming_count_by_member;



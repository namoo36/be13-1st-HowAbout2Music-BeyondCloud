-- Album 테이블
-- rel_date: 연대별 차트를 삽입하는 프로시저에서 WHERE a.rel_date >= ... 조건으로 연도를 필터링하므로 인덱스를 생성합니다.
CREATE INDEX idx_album_rel_date ON Album(rel_date);

-- Song_In_Chart 테이블
-- chart_id, song_id: 이 두 컬럼은 자주 함께 사용되며, 
-- 특히 삭제(DELETE FROM Song_In_Chart WHERE chart_id = ...) 및 삽입 시 활용되므로 복합(composite) 인덱스를 생성합니다.
CREATE INDEX idx_song_in_chart ON Song_In_Chart(chart_id, song_id);


-- 쿼리 실행 계획을 분석하여 인덱스가 제대로 사용되는지 확인합니다.
EXPLAIN SELECT chart_id FROM Chart WHERE name = '신곡';
EXPLAIN SELECT s.song_id FROM Song s WHERE s.genre = 'K-POP' ORDER BY s.Streaming_cnt DESC LIMIT 100;

-- 프로파일 켜기
SET profiling = 1;

-- 실행할 쿼리
SELECT s.song_id FROM Song s WHERE s.genre = 'K-POP' ORDER BY s.Streaming_cnt DESC LIMIT 100;

-- 프로파일링 결과 확인
SHOW PROFILES;

-- 프로파일 끄기
SET profiling = 0;
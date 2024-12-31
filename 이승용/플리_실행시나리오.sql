-- 프로젝트 쿼리 실행
-- 1) 개인 회원 별 플레이리스트 생성
-- make_playlist(유저 아이디, 플리 이름, 공유 유무())

-- 닉네임 첸의 김종대씨는 '나의행복플리'라는 이름으로 공유를 허용해서 플리를 만들고자 한다. 

CALL make_playlist(447, '나의행복플리', 1);
CALL make_playlist(447, '나의기쁨플리', 0);
CALL make_playlist(447, '나의슬픔플리', 0);
CALL make_playlist(447, '나의즐거움플리', 1);

-- 앨범 아이디, 플리 아이디

CALL album_in_ply(122, 4);

CALL make_playlist(377, '플리1', 1);
CALL make_playlist(377, '플리2', 1);
CALL make_playlist(377, '플리3', 1);
CALL make_playlist(377, '플리4', 1);

CALL make_playlist(435, '진소리1', 1);
CALL make_playlist(435, '진소리2', 1);
CALL make_playlist(435, '진소리3', 1);
CALL make_playlist(435, '진소리4', 1);



SELECT *
FROM album;

SELECT *
FROM song_in_playlist;


CALL album_in_ply(8, 9);


SELECT *
FROM playlist
WHERE member_id = 447;

-- 김종대씨가 '나의행복플리'를 만든지 까먹고 똑같은 이름으로 플리를 생성하려고 했으나 실패한다.
-- '이미 있는 이름입니다'이라는 경고와 함께 플리 생성에 실패한다.
CALL make_playlist(447, '나의행복플리', 1);


-- 2) 플리에 노래 추가 
-- add_song_to_playlist(유저 아이디, 플리 아이디, 노래 아이디)
-- 김종대씨는 '나의행복플리'에 '꽃'이라는 노래를 추가하고자 한다.
CALL add_song_to_playlist(447, 1, 53);

SELECT *
FROM song_in_playlist
WHERE playList_id;

-- 김종대씨가 '나의행복플리'에 '꽃'을 넣은줄 깜빡하고 노래를 또 추가하려고 한다.
-- 이 경우 '이미 존재하는 곡입니다.'이라는 문구가 출력된다. 
CALL add_song_to_playlist(447, 1, 53);


-- 3) 아티스트 승인 유저는 노래 등록 가능
-- insert_one_song_only_artist(유저아이디, 곡 이름, 장르, 앨범 이름, 노래 시간)
-- 미노이는 '깨우지 않을게' 라는 발라드 장르의 노래를 추가하고자 한다.
CALL insert_one_song_only_artist(522, '깨우지않을게', '랩', 'NOI MAS', 180);

-- 제대로 삽입되었는지 확인
SELECT * FROM song WHERE NAME = '깨우지않을게';
SELECT * FROM album WHERE NAME = 'NOI MAS';

-- 아티스트가 아닌 일반 유저 김종대씨는 이를 보고 부러워서 자신도 노래를 추가하려고 한다.
-- 이 경우 '일반 유저는 노래를 추가할 수 없습니다.'라는 경고문이 뜨게 된다.
CALL insert_one_song_only_artist(447, '우리 어떻게할까요', 'K-POP', '사랑하는 그대에게S', 191);


-- 아티스트 승인이 된 미노이는 한 번에 노래를 여러개 등록하고자 한다. 
-- 유저 아이디, 곡이름들, 장르, 앨범이름, 노래시간들
-- 미노이는 자신의 새 앨범에 노래 목록들을 추가하고자 한다. 
CALL insert_songs_only_artist(522, '꼬셔야겠어, 오늘 밤은 고비다, This is my life', '랩', 'This is my life', '240, 255, 174');

SELECT a.name AS '앨범명',
		a.member_id,
		s.name AS '노래명',
		s.genre AS '장르',
		s.`length` AS '곡길이'
FROM album AS a
JOIN song AS s ON a.album_id = s.album_id
WHERE member_id = 522 AND a.`name` LIKE 'This is my life';

-- 4) 아티스트이면 내가 올린 노래일 경우 노래를 삭제할 수 있다
-- 미노이는 자신의 노래 중 꼬셔야겠어라는 노래 제목이 부끄러워 해당 노래를 삭제하고자 한다. 
-- my_song_del(유저 아이디, 노래 이름)

CALL my_song_del(522, '꼬셔야겠어');

SELECT *
FROM song
WHERE album_id = 183;

-- 미노이는 '오늘 밤은 고비다'라는 제목도 마음에 들지 않아 '오늘 아침은 고비다'로 바꾸고자 한다.
-- my_song_edit(유저 아이디, 기존 노래 제목, 노래 제목, 장르, 시간)
CALL my_song_edit(522, '오늘 밤은 고비다', '오늘 아침은 고비다', '랩', 255);

SELECT *
FROM song
WHERE album_id = 183;

-- 김종대씨는 미노이 곡의 이전 제목이 마음에 든다. 그러나 그는 아티스트 승인이 되지 않은 일반 유저이다. 
CALL my_song_edit(447, '오늘 아침은 고비다', '오늘 밤은 고비다', '랩', 255);

-- 아티스트인 루피가 나서서 미노이의 곡을 수정하기로 한다. 그러나 그는 해당 노래의 소유자가 아니다. 
CALL my_song_edit(520, '오늘 아침은 고비다', '오늘 밤은 고비다', '랩', 255);


-- 해당 노래에 대한 댓글을 달 수 있다.
-- user_comment (유저 아이디, 노래 아이디, 댓글 내용)
-- 나이가 조금 있는 송대관씨는 신세대 노래에 공감하기 위해 댓글을 달아보기로 했다. 
CALL user_comment(378, 309, '아침은 원래 졸립긴 하지 암');

SELECT *
FROM comment
WHERE song_id = 309;

-- 송대관씨는 자신의 드립이 약간 맘에 안드는지 댓글을 추가로 또 쓰고자 한다.
CALL user_comment(378, 309, '아침이 고비면 저녁은 더하기인가?ㅎㅎ');

SELECT *
FROM comment
WHERE song_id = 309;

-- 송대관씨는 자신의 이러한 행동이 아주 약간은 주책같이 느껴져 아침 드립은 지우고자 한다. 
CALL user_comment_del(378, 2);
SELECT *
FROM comment
WHERE song_id = 309;


-- 앨범에 대한 좋아요 남기기
-- member_add_album_like(유저 아이디, 앨범 아이디)
-- 송대관씨는 댓글을 씀과 동시에 미노이의 앨범에 좋아요를 남기기로 결심한다.
CALL member_add_album_like(378, 174);

SELECT *
FROM like_cnt
WHERE album_id = 174;

-- 너무 좋은 앨범인 것 같아 송대관씨는 또 좋아요를 추가하고자 하지만 더는 좋아요가 추가되지 않는다. 
CALL member_add_album_like(378, 174);

-- 이내 자신의 행동이 너무 과했다고 생각했는지 앨범에 대한 좋아요를 철회하기로 한다.
-- member_minus_album_like(유저 아이디, 앨범 아이디)
CALL member_minus_album_like(378, 174);

SELECT *
FROM like_cnt
WHERE album_id = 174;

-- 좋아요 취소를 실수로 한 번 더 눌렀더니, 좋아요를 누른 적이 없는 노래라는 경고문구가 뜬다.
CALL member_minus_album_like(378, 174);


-- 노래 제목 검색
-- search_song_title(노래 제목 이름이 들어간 경우 ->)
-- '사랑' 이 들어간 노래들 중 재생 횟수가 높은 순서대로 노래를 출력하고자 한다. 
CALL search_song_title('사랑'); 

-- 가수 이름 검색
-- search_singer_name(가수 이름)
CALL search_singer_name('미노이');

-- 장르 이름 검색
-- search_genre(장르 이름)
CALL search_genre('랩');


-- 앨범 전체 플리에 추가
-- 김종대씨는 자신의 '행복플리'에 미노이의 새 앨범 전체를 넣고 싶어한다.
-- album_in_ply(앨범 아이디, 플리 아이디)

SELECT *
FROM album
WHERE member_id = 522;

CALL album_in_ply(183, 1);

SELECT *
FROM song_in_playlist AS sp
JOIN song AS s ON sp.song_id = s.song_id
WHERE playlist_id = 1;



-- 김종대씨는 현재 재생 목록에 '오늘 아침은 고비다'라는 노래를 넣고 싶습니다.
-- 해당 노래를 재생하면 현재 재생 목록이 없었을 경우 재생목록을 새로 생성한 뒤, 
-- 재생중인 노래에 노래를 추가하고
-- 현재 재생 목록에도 노래를 추가합니다. 
CALL play_song_current_ply(522, 304);

SELECT *
FROM nowplaylist
WHERE member_id = 522;

SELECT nowPlaylist_id, s.song_id, s.name, Streaming_cnt
FROM song_in_nowplaylist AS sn
JOIN song AS s ON s.song_id = sn.song_id
WHERE nowplaylist_id = 2;


-- 동일한 노래를 또 추가할 경우 재생 중인 노래는 변하지 않고, 현재 재생 목록에도 중복된 노래는 들어가지 않습니다.
-- 다만 재생중인 노래에 등록된 시간을 바꿀 뿐입니다. 
CALL play_song_current_ply(522, 303);

SELECT *
FROM song_in_nowplaylist
WHERE nowplaylist_id = 1;

-- 김종대씨는 다른 노래를 듣고 싶어서 미노이의 'This is life'라는 노래를 추가하고자 합니다.
-- 현재 재생 목록 아이디는 변하지 않습니다.
-- 현재 재생 목록에 담긴 노래에 304번 노래가 추가됩니다.
-- 재생중인 노래는 304번으로 바뀝니다. 
-- 원래 듣던 노래는 재생목록에는 그대로 존재하게 됩니다. 
CALL play_song_current_ply(522, 304);

SELECT *
FROM song_in_nowplaylist
WHERE nowplaylist_id = 1;

-- 재생을 시작하게 되면 스트리밍 횟수가 1씩 증가하게 됩니다. 
-- 김종대씨가 노래를 다 들은 뒤 자동으로 재생되는 다음 노래가 궁금해서 확인해봅니다.
-- 303번 노래를 들은 뒤에 304번 노래를 재생했을 경우, 그 이전에 가장 최근에 재생했던 노래가 다음 노래가 됩니다. 
CALL next_cur_song(522, 304);


-- 현재 재생 목록에 노래를 추가할 수 있다.
-- 노래가 이미 있는 경우 '이미 있는 노래 입니다.' 출력
CALL add_cur_song_ply(522, 304);

-- 현재 재생 목록에 노래를 뺄 수 있다. 
-- 현재 재생 목록이 없는 경우 -> '현재 재생 목록이 없습니다.'
-- 현재 재생 목록에 노래가 없는 경우 -> '현재 재생 목록에 해당 노래가 없습니다.'
CALL del_cur_song_ply(522, 304);

SELECT *
FROM nowplaylist
WHERE member_id = 522;

SELECT *
FROM song_in_nowplayList
WHERE nowPlayList_id = 1;

SELECT *
FROM listening_song
WHERE nowPlayList_id = 1;

SELECT *
FROM song
WHERE song_id = 303;

SELECT *
FROM streaming_count_by_member;

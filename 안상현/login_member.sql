show databases;
use beyondcloud;

show tables;

select * from Song;

# 개선이 필요한 사항
-- 1. member 테이블의 email, nickname 컬럼에 unique 설정이 필요한가요?


#로그인 / 회원가입
-- 회원가입 : 회원 정보를 입력하면 회원 정보가 저장된다.
desc Member;

INSERT INTO `Member` (password, name, email, nickname) VALUES ('2222','둘리','duly@naver.com','dulygreen');

-- 회원탈퇴 : 회원 정보와 관련된 데이터가 삭제된다.
DELETE FROM `Member` WHERE email = '?' and password = '?';
DELETE FROM `Member` WHERE member_id = ?;

-- 로그인 : 아이디와 비밀번호로 로그인 시 로그인 된다.
UPDATE `Member` SET isLogin = 1 WHERE member_id = ?;
UPDATE `Member` SET isLogin = 1 WHERE email = '?';
UPDATE `Member` SET isLogin = 1 WHERE email = '?' and password = '?';

-- 로그아웃
UPDATE `Member` SET isLogin = 0 WHERE member_id = ?;
UPDATE `Member` SET isLogin = 0 WHERE email = '?';

-- 회원 정보 수정 : 내 정보를 수정할 수 있다.
UPDATE `Member` SET password = '?', name = '?', nickname = '?' where email = '?';

#아티스트 
-- 관리자의 승인을 받으면 아티스트가 될 수 있다.
UPDATE `Member` SET role = '?' where email = '?';

#아래 요구사항은 여기서 처리하기에 약간 애매해서 보류하였습니다.
-- 아티스트는 노래를 등록할 수 있다.
-- 등록한 노래를 관리할 수 있다.
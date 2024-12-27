create database mockup_beyondcloud default character set utf8;
use mockup_beyondcloud;

#회원가입 : 회원 정보를 입력하면 회원 정보가 저장된다.

delimiter $$
CREATE OR REPLACE PROCEDURE makeMemberProc (
	IN inputName varchar(20),
	IN inputPassword varchar(20),
	IN inputEmail varchar(255),
	IN inputNickname varchar(50)
)
BEGIN 
	INSERT INTO Member (name, password, email, nickname) VALUES (inputName,inputPassword,inputEmail,inputNickname);
END $$
delimiter ;

call makeMemberProc('둘리','2222','duly@naver.com','dulygreen');

#회원탈퇴 : 회원 정보와 관련된 데이터가 삭제된다.
delimiter $$
CREATE OR REPLACE PROCEDURE deleteMemberProc(
	IN inputMemberId bigint(20)
)
BEGIN 
	DELETE FROM Member WHERE member_id = inputMemberId;
END $$
delimiter ;

call deleteMemberProc(3);


-- 로그인 : 아이디와 비밀번호로 로그인 시 로그인 된다.
delimiter $$
CREATE OR REPLACE PROCEDURE loginMemberProc(
	IN inputEmail varchar(255),
	IN inputPassword varchar(20)
)
BEGIN 
	UPDATE Member SET isLogin = 1 WHERE email = inputEmail and password = inputPassword;
END $$
delimiter ;

call loginMemberProc('duly@naver.com','2222');


-- 로그아웃
delimiter $$
CREATE OR REPLACE PROCEDURE logoutMemberProc(
	IN inputMemberId bigint(20)
)
BEGIN 
	UPDATE Member SET isLogin = 0 WHERE member_id = inputMemberId;
END $$
delimiter ;

call logoutMemberProc(4);


-- 회원 정보 수정 : 내 정보를 수정할 수 있다.
delimiter $$
CREATE OR REPLACE PROCEDURE modifyMemberProc(
	IN inputName varchar(20),
	IN inputPassword varchar(20),
	IN inputNickname varchar(50),
	IN inputEmail varchar(255)
)
BEGIN 
	UPDATE Member SET name = inputName, password = inputPassword, nickname = inputNickname where email = inputEmail;
END $$
delimiter ;

call modifyMemberProc('하니','1234','달려라하니','duly@naver.com');


#아티스트 
-- 관리자의 승인을 받으면 아티스트가 될 수 있다.
delimiter $$
CREATE OR REPLACE PROCEDURE confirmArtistProc(
	IN inputMemberId varchar(20)
)
BEGIN 
	UPDATE Member SET role = 'Arti' where member_id = inputMemberId;
END $$
delimiter ;

call confirmArtistProc(4);


#아래 요구사항은 여기서 처리하기에 약간 애매해서 보류하였습니다.
-- 아티스트는 노래를 등록할 수 있다.
-- 등록한 노래를 관리할 수 있다.

#1. 회원가입 : 회원 정보를 입력하면 회원 정보가 저장된다.
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


#2. 로그인 : 아이디와 비밀번호로 로그인 시 로그인 된다.
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


#3. 로그아웃 : 564번 회원이 로그아웃 버튼을 클릭하면 로그아웃 된다.
delimiter $$
CREATE OR REPLACE PROCEDURE logoutMemberProc(
	IN inputMemberId bigint(20)
)
BEGIN 
	UPDATE Member SET isLogin = 0 WHERE member_id = inputMemberId;
END $$
delimiter ;

call logoutMemberProc(564);


#4. 회원정보 수정 : 둘리회원의 정보중 닉네임, 비밀번호을 수정할 수 있다.
delimiter $$
CREATE OR REPLACE PROCEDURE modifyMemberProc(
	IN inputPassword varchar(20),
	IN inputNickname varchar(50),
	IN inputEmail varchar(255)
)
BEGIN 
	UPDATE Member SET nickname = inputNickname, password = inputPassword  where email = inputEmail;
END $$
delimiter ;

call modifyMemberProc('dulyblue','1234','duly@naver.com');


#5. 아티스트  : 관리자의 승인을 받으면 아티스트가 될 수 있다.
delimiter $$
CREATE OR REPLACE PROCEDURE confirmArtistProc(
	IN inputMemberId bigint(20)
)
BEGIN 
	UPDATE Member SET role_code = 2 where member_id = inputMemberId;
END $$
delimiter ;

call confirmArtistProc(564);


#6. 회원탈퇴 : 564 "둘리"회원 정보와 관련된 데이터가 삭제된다.
delimiter $$
CREATE OR REPLACE PROCEDURE deleteMemberProc(
	IN inputMemberId bigint(20)
)
BEGIN 
	DELETE FROM Member WHERE member_id = inputMemberId;
END $$
delimiter ;

call deleteMemberProc(564);


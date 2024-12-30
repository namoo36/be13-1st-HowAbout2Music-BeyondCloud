
#1. 회원가입 : 회원 정보를 입력하면 회원 정보가 저장된다.'
-- 이름, 비밀번호, 이메일, 닉네임 입력 받아서 회원 저장
-- 이메일, 닉네임에 한해서 중복된 값이 없도록 수정
delimiter $$
CREATE OR REPLACE PROCEDURE makeMemberProc (
	IN inputName varchar(20),
	IN inputPassword varchar(20),
	IN inputEmail varchar(255),
	IN inputNickname varchar(50)
)
BEGIN 
	IF EXISTS(
		SELECT *
		FROM member
		WHERE email LIKE inputEmail
	) SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 가입한 이메일입니다.';
	ELSEIF EXISTS(
		SELECT *
		FROM member
		WHERE nickname = inputNickname
	) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '이미 있는 닉네임입니다.';
	ELSE	 
		INSERT INTO Member (name, password, email, nickname) VALUES (inputName,inputPassword,inputEmail,inputNickname);
	END IF;
END $$
delimiter ;

call makeMemberProc('둘리','2222','duly@naver.com','dulygreen');

-- 동일한 닉네임을 사용하려는 경우
CALL makeMemberProc('고길동','2222','gildong@naver.com','dulygreen');

-- 이미 가입한 이메일을 사용하려는 경우
CALL makeMemberProc('고길동','2222','duly@naver.com','gildongswordmaster');

SELECT *
FROM MEMBER
WHERE NAME = '둘리';




#2. 로그인 : 가입 시 작성했던 이메일과 비밀번호로 로그인함. 
-- 이메일이 없을 시 -> 가입된 적 없는 이메일입니다.
-- 비밀번호가 맞지 않을 시 -> 비밀번호가 올바르지 않습니다.
delimiter $$
CREATE OR REPLACE PROCEDURE loginMemberProc(
	IN inputEmail varchar(255),
	IN inputPassword varchar(20)
)
BEGIN 
	IF NOT EXISTS(
		SELECT *
		FROM member
		WHERE email LIKE inputEmail
	) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '가입된 적 없는 이메일입니다.';
	ELSEIF NOT EXISTS (
		SELECT *
		FROM member 
		WHERE email LIKE inputEmail AND PASSWORD LIKE inputPassword
	) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '비밀번호가 일치하지 않습니다. ';
	ELSE 
		UPDATE Member SET isLogin = 1 WHERE email = inputEmail and password = inputPassword;
	END IF;
END $$
delimiter ;

-- 로그인 성공
call loginMemberProc('duly@naver.com','2222');

-- 비밀번호가 일치하지 않는 경우
call loginMemberProc('duly@naver.com','2221');

-- 이메일가입된 적 없는 이메일인 경우
call loginMemberProc('dulyy@naver.com','2222');

-- 로그인 시 isLogin 정보가 0->1로 변경된다.
SELECT *
FROM MEMBER
WHERE email = 'duly@naver.com';




#3. 로그아웃 : 564번 회원이 로그아웃 버튼을 클릭하면 로그아웃 된다.
delimiter $$
CREATE OR REPLACE PROCEDURE logoutMemberProc(
	IN inputMemberId bigint(20)
)
BEGIN 
	UPDATE Member SET isLogin = 0 WHERE member_id = inputMemberId;
END $$
delimiter ;

call logoutMemberProc(565);

-- 로그아웃 시 isLogin 정보가 1 -> 0으로 변경된다.
SELECT *
FROM MEMBER
WHERE email = 'duly@naver.com';




#4. 회원정보 수정 : 둘리회원의 정보중 닉네임, 비밀번호을 수정할 수 있다.
-- 회원 아이디를 입력 받아야 한다.
-- 패스워드, 닉네임, 이메일을 입력 받아서 정보를 수정한다.
-- 로그인 상태가 1인 경우에만 회원 정보 수정이 가능하다.
delimiter $$
CREATE OR REPLACE PROCEDURE modifyMemberProc(
	IN u_id BIGINT(20),
	IN inputPassword varchar(20),
	IN inputNickname varchar(50),
	IN inputEmail varchar(255)
)
BEGIN 
DECLARE cur_is_login TINYINT(4);

	SELECT isLogin INTO cur_is_login
	FROM member 
	WHERE member_id = u_id;
	
	IF cur_is_login = 1
	THEN 
		UPDATE Member SET nickname = inputNickname, password = inputPassword  where email = inputEmail;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '로그인 되어 있지 않습니다.';
	END IF;
END $$
delimiter ;

call modifyMemberProc(565,'1234','dulyblue','duly@naver.com');

-- 회원 정보 수정 -> 패스워드와 닉네임을 변경할 수 있다.
SELECT *
FROM MEMBER
WHERE email = 'duly@naver.com';





#5. 아티스트  : 관리자의 승인을 받으면 아티스트가 될 수 있다.
-- 해당하는 회원 아이디가 존재하지 않는 경우 ' 존재하지 않는 회원입니다.'라는 경고 문구가 뜬다.
delimiter $$
CREATE OR REPLACE PROCEDURE confirmArtistProc(
	IN inputMemberId bigint(20)
)
BEGIN 
DECLARE c_member_id BIGINT(20);

	SELECT member_id INTO c_member_id
	FROM member 
	WHERE member_id = inputMemberId; 
	
	IF ISNULL(c_member_id) 
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '존재하지 않는 회원입니다.';
	ELSE 	
		UPDATE Member SET role_code = 2 where member_id = inputMemberId;
	END IF;
END $$
delimiter ;

call confirmArtistProc(564);

-- 멤버 아이디가 564인 유저의 role_code가 2로 변경된다.
SELECT *
FROM MEMBER
WHERE member_id = 564;




#6. 회원탈퇴 : 564 "둘리"회원 정보와 관련된 데이터가 삭제된다.
-- 회원 아이디가 존재하지 않는 경우 '존재하지 않는 회원입니다.'라는 경고 문구가 뜬다.
delimiter $$
CREATE OR REPLACE PROCEDURE deleteMemberProc(
	IN inputMemberId bigint(20)
)
BEGIN 
DECLARE c_member_id BIGINT(20);

	SELECT member_id INTO c_member_id
	FROM member 
	WHERE member_id = inputMemberId; 
	
	IF ISNULL(c_member_id) 
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '존재하지 않는 회원입니다.';
	ELSE 	
		DELETE FROM Member WHERE member_id = inputMemberId;
	END IF;
END $$
delimiter ;



call deleteMemberProc(564);
-- 해당 아이디의 회원은 삭제된다.
SELECT *
FROM MEMBER
WHERE member_id = 564;



-- 회원 관리 항목에서 member_id로의 검색이 많아 member_id 인덱스를 미리 생성해두었다.
CREATE INDEX idx_member_id ON member(member_id);

EXPLAIN (
	SELECT *
	FROM member
	WHERE member_id = 522
); 

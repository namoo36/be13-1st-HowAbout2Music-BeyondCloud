-- --------------------------------------------------------
-- 호스트:                          beyondclouddb.cj4mw46g2m7w.us-east-2.rds.amazonaws.com
-- 서버 버전:                        10.4.34-MariaDB-log - Source distribution
-- 서버 OS:                        Linux
-- HeidiSQL 버전:                  12.7.0.6850
-- --------------------------------------------------------

/*!40101 SET @ObeyondcloudLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- beyondcloud 데이터베이스 구조 내보내기
CREATE DATABASE IF NOT EXISTS `beyondcloud` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `beyondcloud`;

-- 테이블 beyondcloud.member 구조 내보내기
CREATE TABLE IF NOT EXISTS `member` (
  `member_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `password` varchar(20) NOT NULL,
  `name` varchar(30) NOT NULL,
  `isLogin` tinyint(1) NOT NULL DEFAULT 0,
  `reg_date` date NOT NULL DEFAULT curdate(),
  `email` varchar(50) NOT NULL,
  `nickname` varchar(50) NOT NULL,
  `role_code` int(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`member_id`),
  KEY `FK_Role_TO_Member_1` (`role_code`),
  CONSTRAINT `FK_Role_TO_Member_1` FOREIGN KEY (`role_code`) REFERENCES `role` (`role_code`)
) ENGINE=InnoDB AUTO_INCREMENT=563 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 beyondcloud.album 구조 내보내기
CREATE TABLE IF NOT EXISTS `album` (
  `album_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `member_id` bigint(20) NOT NULL,
  `Field` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`album_id`),
  KEY `FK_Member_TO_Album_1` (`member_id`),
  CONSTRAINT `FK_Member_TO_Album_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.album:~0 rows (대략적) 내보내기
DELETE FROM `album`;

-- 테이블 beyondcloud.chart 구조 내보내기
CREATE TABLE IF NOT EXISTS `chart` (
  `chart_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(10) NOT NULL,
  PRIMARY KEY (`chart_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.chart:~0 rows (대략적) 내보내기
DELETE FROM `chart`;

-- 테이블 beyondcloud.comment 구조 내보내기
CREATE TABLE IF NOT EXISTS `comment` (
  `comment_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `content` varchar(255) NOT NULL,
  `write_date` date NOT NULL DEFAULT curdate(),
  `member_id` bigint(20) NOT NULL,
  `song_id` bigint(20) NOT NULL,
  PRIMARY KEY (`comment_id`),
  KEY `FK_Member_TO_Comment_1` (`member_id`),
  KEY `FK_Song_TO_Comment_1` (`song_id`),
  CONSTRAINT `FK_Member_TO_Comment_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  CONSTRAINT `FK_Song_TO_Comment_1` FOREIGN KEY (`song_id`) REFERENCES `song` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.comment:~0 rows (대략적) 내보내기
DELETE FROM `comment`;

-- 테이블 beyondcloud.like_cnt 구조 내보내기
CREATE TABLE IF NOT EXISTS `like_cnt` (
  `like_cnt_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `member_id` bigint(20) NOT NULL,
  `album_id` bigint(20) NOT NULL,
  PRIMARY KEY (`like_cnt_id`,`member_id`,`album_id`),
  KEY `FK_Member_TO_like_cnt_1` (`member_id`),
  KEY `FK_Album_TO_like_cnt_1` (`album_id`),
  CONSTRAINT `FK_Album_TO_like_cnt_1` FOREIGN KEY (`album_id`) REFERENCES `album` (`album_id`),
  CONSTRAINT `FK_Member_TO_like_cnt_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.like_cnt:~0 rows (대략적) 내보내기
DELETE FROM `like_cnt`;



-- 테이블 데이터 beyondcloud.member:~192 rows (대략적) 내보내기
DELETE FROM `member`;
INSERT INTO `member` (`member_id`, `password`, `name`, `isLogin`, `reg_date`, `email`, `nickname`, `role_code`) VALUES
	(371, '1234', 'SHINee', 0, '2024-12-26', 'shinee@by.kr', '샤이니', 2),
	(372, '1234', '신정환', 0, '2024-12-26', 'shinyu@by.kr', '신유', 0),
	(373, '1234', '조테리', 0, '2024-12-26', 'shyboy@by.kr', '샤이보이토이', 2),
	(374, '1234', '임현식', 0, '2024-12-26', 'sik@by.kr', '임현식', 0),
	(375, '1234', '이우', 0, '2024-12-26', 'smallstar@music.com', '이우', 0),
	(376, '8440', '소녀시대', 0, '2024-12-26', 'SNSD@by.kr', '소녀시대', 2),
	(377, '1234', '김용선', 0, '2024-12-26', 'sola@music.com', '솔라', 2),
	(378, '1234', '송대관', 0, '2024-12-26', 'songd@by.kr', '송대관', 2),
	(379, '1234', '권순일', 0, '2024-12-26', 'soonil@by.kr', '권순일', 0),
	(380, '1234', '장다혜', 0, '2024-12-26', 'spring@music.com', '헤이즈', 2),
	(381, '1234', '임한별', 0, '2024-12-26', 'starmoon@music.com', '임한별', 2),
	(382, '1234', '주범진', 0, '2024-12-26', 'starwind@music.com', '범진', 0),
	(383, '1234', '이창섭', 0, '2024-12-26', 'sub@by.kr', '이창섭', 0),
	(384, '1234', '최수빈', 0, '2024-12-26', 'subin@by.kr', '수빈', 0),
	(385, '1234', '김준면', 0, '2024-12-26', 'suho@by.kr', '수호', 0),
	(386, '1234', '동영배', 0, '2024-12-26', 'sun@by.kr', '태양', 0),
	(387, '1234', '박성진', 0, '2024-12-26', 'sungjin@by.kr', '성진', 0),
	(388, '8910', '이순규', 0, '2024-12-26', 'sunny@by.kr', '써니', 0),
	(389, '1234', 'seveenteen', 0, '2024-12-26', 'svt@by.kr', '세븐틴', 2),
	(390, '4775', '최수영', 0, '2024-12-26', 'swim@by.kr', '수영', 0),
	(391, '3417', '설윤아', 0, '2024-12-26', 'sya@by.kr', '설윤', 0),
	(392, '1234', '김태형', 0, '2024-12-26', 'taehyung@by.kr', '뷔', 0),
	(393, '1234', '이태민', 0, '2024-12-26', 'taemin@by.kr', '태민', 0),
	(394, '3583', '김태연', 0, '2024-12-26', 'teng@by.kr', '태연', 0),
	(395, '1234', '강태현', 0, '2024-12-26', 'Thyun@by.kr', '태현', 0),
	(396, '12song_unlike`Member', '김태형', 0, '2024-12-26', 'treestar@music.com', '폴킴', 2),
	(397, '1845', 'TWICE', 0, '2024-12-26', 'TWICE@by.kr', 'TWICE', 2),
	(398, '1234', '투AM', 0, '2024-12-26', 'twoam@music.com', '"2AM"', 2),
	(399, '1234', 'TWS', 0, '2024-12-26', 'tws@by.kr', '투어스', 2),
	(400, '1234', '투모로우바이투게더', 0, '2024-12-26', 'TXT@by.kr', '투모로우바이투게더', 2),
	(401, '4660', '저우쯔위', 0, '2024-12-26', 'tzuyu@by.kr', '쯔위', 0),
	(402, '1234', 'Urban Zakapa', 0, '2024-12-26', 'urbanzakapa@by.kr', '어반자카파', 2),
	(403, '1234', '최한솔', 0, '2024-12-26', 'vernon@by.kr', '버논', 0),
	(404, '1467', '쑹첸', 0, '2024-12-26', 'vic@by.kr', '빅토리아', 0),
	(405, '1234', '김정우', 0, '2024-12-26', 'water@music.com', '정우', 0),
	(406, '1667', '손승완', 0, '2024-12-26', 'wendy@by.kr', '웬디', 0),
	(407, '1234', '서영주', 0, '2024-12-26', 'whitecloud@music.com', '너드커넥션', 2),
	(408, '1234', '노을', 0, '2024-12-26', 'whitestar@music.com', '노을', 2),
	(409, '1234', '박재정', 0, '2024-12-26', 'winterbird@music.com', '박재정', 0),
	(410, '2465', '장원영', 0, '2024-12-26', 'wonyoung@by.kr', '장원영', 0),
	(411, '1234', '려욱', 0, '2024-12-26', 'wook@music.com', '려욱', 2),
	(412, '1234', '이지훈', 0, '2024-12-26', 'woozi@by.kr', '우지', 0),
	(413, '1234', '전원우', 0, '2024-12-26', 'ww@by.kr', '원우', 0),
	(414, '1234', '김민석', 0, '2024-12-26', 'xiu@by.kr', '시우민', 0),
	(415, '6319', '황예지', 0, '2024-12-26', 'yeji@by.kr', '예지(itzy)', 0),
	(416, '1234', '전예지', 0, '2024-12-26', 'yejiii@by.kr', '예지(경서예지)', 0),
	(417, '8711', '김예림', 0, '2024-12-26', 'yeri@by.kr', '예리', 0),
	(418, '1234', '육성재', 0, '2024-12-26', 'yook@by.kr', '육성재', 0),
	(419, '9313', '임윤아', 0, '2024-12-26', 'yoon-a@by.kr', '윤아', 0),
	(420, '1234', '윤정한', 0, '2024-12-26', 'yoon@by.kr', '정한', 0),
	(421, '9808', '황미영', 0, '2024-12-26', 'young@by.kr', '티파니', 0),
	(422, '1234', '박영탁', 0, '2024-12-26', 'youngtak@by.kr', '영탁', 2),
	(423, '1234', '최영재', 0, '2024-12-26', 'youngjae@by.kr', '영재', 0),
	(424, '1234', '강영현', 0, '2024-12-26', 'youngk@by.kr', 'Young K', 0),
	(425, '1234', '박용인', 0, '2024-12-26', 'younin@by.kr', '박용인', 0),
	(426, '8323', '신유나', 0, '2024-12-26', 'yuna@by.kr', '유나', 0),
	(427, '9580', '권유리', 0, '2024-12-26', 'yuri@by.kr', '유리', 0),
	(428, '8241', '안유진', 0, '2024-12-26', 'yuzin@by.kr', '안유진', 0),
	(429, '7206', '김애리', 0, '2024-12-26', 'aeri@by.kr', '지젤', 0),
	(430, '6606', 'Aespa', 0, '2024-12-26', 'Aespa@by.kr', 'Aespa', 2),
	(431, '1234', '권정열', 0, '2024-12-26', 'afterdal@music.com', '10CM', 2),
	(432, '1234', '이미자', 0, '2024-12-26', 'already@by.kr', '이미자', 2),
	(433, '6934', '류이윈', 0, '2024-12-26', 'amber@by.kr', '엠버', 0),
	(434, '3463', '김가을', 0, '2024-12-26', 'autumn@by.kr', '가을', 0),
	(435, '7512', '배진솔', 0, '2024-12-26', 'bae@by.kr', '베이', 0),
	(436, '1234', '변백현', 0, '2024-12-26', 'bbh@by.kr', '백현', 0),
	(437, '1234', '최재호', 0, '2024-12-26', 'best@by.kr', '최자', 0),
	(438, '1234', '빅뱅', 0, '2024-12-26', 'bigbang@by.kr', '빅뱅', 2),
	(439, '1234', '강대성', 0, '2024-12-26', 'bigStar@by.kr', '대성', 0),
	(440, '1234', '검정치마', 0, '2024-12-26', 'blackskirt@by.kr', '검정치마', 2),
	(441, '1234', '송하예', 0, '2024-12-26', 'bluesol@music.com', '송하예', 2),
	(442, '1234', '부승관', 0, '2024-12-26', 'boo@by.kr', '승관', 0),
	(443, '1234', 'BTOB', 0, '2024-12-26', 'btob@by.kr', '비투비', 2),
	(444, '1234', 'BTS', 0, '2024-12-26', 'bts@by.kr', '방탄소년단', 2),
	(445, '1234', '최범규', 0, '2024-12-26', 'bum@by.kr', '범규', 0),
	(446, '1234', '박찬열', 0, '2024-12-26', 'chan10@by.kr', '찬열', 0),
	(447, '1234', '김종대', 0, '2024-12-26', 'chen@by.kr', '첸', 0),
	(448, '1599', '손채영', 0, '2024-12-26', 'cheng@by.kr', '채영', 0),
	(449, '1234', '최연준', 0, '2024-12-26', 'chyo@by.kr', '연준', 0),
	(450, '1234', '최승철', 0, '2024-12-26', 'coups@by.kr', '에스쿱스', 0),
	(451, '8979', '이채령', 0, '2024-12-26', 'cr@by.kr', '채령', 0),
	(452, '1234', '신효섭', 0, '2024-12-26', 'crush@music.com', 'Crush', 2),
	(453, '1234', '서명호', 0, '2024-12-26', 'd8@by.kr', '디에잇', 0),
	(454, '1234', 'DAY6', 0, '2024-12-26', 'day6@by.kr', '데이식스', 2),
	(455, '1234', '이찬', 0, '2024-12-26', 'dino@by.kr', '디노', 0),
	(456, '1234', '이석민', 0, '2024-12-26', 'dk@by.kr', '도겸', 0),
	(457, '1234', '도경수', 0, '2024-12-26', 'do@by.kr', '디오', 0),
	(458, '1234', '김윤성', 0, '2024-12-26', 'dogNose@by.kr', '개코', 0),
	(459, '1234', '김도훈', 0, '2024-12-26', 'dohoon@by.kr', '도훈', 0),
	(460, '1234', '윤도운', 0, '2024-12-26', 'dowoon@by.kr', '도운', 0),
	(461, '8305', '김다현', 0, '2024-12-26', 'dy@by.kr', '다현', 0),
	(462, '1234', '다이나믹 듀오', 0, '2024-12-26', 'dynamicduo@by.kr', '다이나믹 듀오', 2),
	(463, '1234', '한성호', 0, '2024-12-26', 'eclipse@music.com', '이클립스', 2),
	(464, '1234', 'EXO', 0, '2024-12-26', 'exo@by.kr', '엑소', 2),
	(465, '1234', '허각', 0, '2024-12-26', 'flower@music.com', '허각', 2),
	(466, '2998', 'f(x)', 0, '2024-12-26', 'fx@by.kr', 'f(x)', 2),
	(467, '1234', '송가인', 0, '2024-12-26', 'gain@by.kr', '송가인', 2),
	(468, '1234', '강희건', 0, '2024-12-26', 'garry@by.kr', '개리', 0),
	(469, '1234', '권지용', 0, '2024-12-26', 'gDragon@by.kr', '지드래곤', 0),
	(470, '1234', '고윤하', 0, '2024-12-26', 'green@music.com', '윤하', 2),
	(471, '1234', '원경서', 0, '2024-12-26', 'gyoungseo@by.kr', '경서', 0),
	(472, '1234', '한쩐', 0, '2024-12-26', 'hanjin@by.kr', '한진', 0),
	(473, '1234', '한지수', 0, '2024-12-26', 'hanroro@by.kr', '한로로', 2),
	(474, '1234', '이희상', 0, '2024-12-26', 'heesang@by.kr', '이희상', 2),
	(475, '1234', '임영웅', 0, '2024-12-26', 'hero@by.kr', '임영웅', 2),
	(476, '1234', '조휴일', 0, '2024-12-26', 'holyday@by.kr', '조휴일', 0),
	(477, '1234', '권순영', 0, '2024-12-26', 'hoshi@by.kr', '호시', 0),
	(478, '1234', '조현아', 0, '2024-12-26', 'huna@by.kr', '조현아', 0),
	(479, '1234', '카이카말휴닝', 0, '2024-12-26', 'huuning@by.kr', '휴닝카이', 0),
	(480, '9509', '배주현', 0, '2024-12-26', 'IRENE@by.kr', '아이린', 0),
	(481, '6593', 'ITZY', 0, '2024-12-26', 'ITZY@by.kr', 'ITZY', 2),
	(482, '1234', '이지은', 0, '2024-12-26', 'iu@music.com', 'IU', 2),
	(483, '2205', 'IVE', 0, '2024-12-26', 'IVE@by.kr', 'IVE', 2),
	(484, '1234', '장윤정', 0, '2024-12-26', 'jang@by.kr', '장윤정', 2),
	(485, '2422', '김제니', 0, '2024-12-26', 'jennie@by.kr', '제니', 0),
	(486, '1234', '김종현', 0, '2024-12-26', 'jh@by.kr', '종현', 0),
	(487, '1234', '정호석', 0, '2024-12-26', 'jho@by.kr', '제이홉', 0),
	(488, '1234', '한지훈', 0, '2024-12-26', 'jihoon@by.kr', '지훈', 0),
	(489, '2158', '박지효', 0, '2024-12-26', 'jihyo@by.kr', '지효', 0),
	(490, '1234', '김석진', 0, '2024-12-26', 'jin@by.kr', '진', 0),
	(491, '1234', '정진운', 0, '2024-12-26', 'jinun@by.kr', '정진운', 0),
	(492, '9969', '김지수', 0, '2024-12-26', 'jisoo@by.kr', '지수', 0),
	(493, '1884', '장규진', 0, '2024-12-26', 'jkj@by.kr', '규진', 0),
	(494, '1234', '조권', 0, '2024-12-26', 'jkun@by.kr', '조권', 0),
	(495, '1234', '주현미', 0, '2024-12-26', 'joo@by.kr', '주현미', 2),
	(496, '1234', '홍지수', 0, '2024-12-26', 'joshua@by.kr', '조슈아', 0),
	(497, '5824', '박수영', 0, '2024-12-26', 'joy@by.kr', '조이', 0),
	(498, '1234', '문준휘', 0, '2024-12-26', 'jun@by.kr', '준', 0),
	(499, '1234', '전정국', 0, '2024-12-26', 'junjung@by.kr', '정국', 0),
	(500, '8334', '김지우', 0, '2024-12-26', 'jw@by.kr', '지우', 0),
	(501, '8764', '유정연', 0, '2024-12-26', 'jy@by.kr', '정연', 0),
	(502, '1234', '김종인', 0, '2024-12-26', 'kai@by.kr', '카이', 0),
	(503, '5794', '유지민', 0, '2024-12-26', 'kar@by.kr', '카리나', 0),
	(504, '1234', '김범수', 0, '2024-12-26', 'kbs@music.com', '김범수', 2),
	(505, '1234', '김기범', 0, '2024-12-26', 'key@by.kr', '키', 0),
	(506, '1159', '김효연', 0, '2024-12-26', 'khy@by.kr', '효연', 0),
	(507, '1234', '이경민', 0, '2024-12-26', 'kmin@by.kr', '경민', 0),
	(508, '1234', '구창모', 0, '2024-12-26', 'koo@by.kr', '창모', 2),
	(509, '4642', '정수정', 0, '2024-12-26', 'krystal@by.kr', '크리스탈', 0),
	(510, '1234', '이창민', 0, '2024-12-26', 'lcmin@by.kr', '이창민', 0),
	(511, '1234', '서혜린', 0, '2024-12-26', 'lean@music.com', '혜린', 2),
	(512, '1234', '김민겸', 0, '2024-12-26', 'leeler@by.kr', '릴러말즈', 2),
	(513, '2419', '이현서', 0, '2024-12-26', 'leeseo@by.kr', '이서', 0),
	(514, '1234', '리쌍', 0, '2024-12-26', 'leessang@by.kr', '리쌍', 2),
	(515, '7540', '최지수', 0, '2024-12-26', 'lia@by.kr', '리아', 0),
	(516, '1234', '경서예지', 0, '2024-12-26', 'lighthouse@music.com', '경서예지', 2),
	(517, '5919', '라리사 마노반', 0, '2024-12-26', 'lisa@by.kr', '리사', 0),
	(518, '1853', '김지원', 0, '2024-12-26', 'liz@by.kr', '리즈', 0),
	(519, '8980', 'Lily Jin Park Morrow', 0, '2024-12-26', 'lj@by.kr', '릴리', 0),
	(520, '1234', '이진용', 0, '2024-12-26', 'loopy@by.kr', '루피', 2),
	(521, '9727', '박선영', 0, '2024-12-26', 'luna@by.kr', '루나', 0),
	(522, '1234', '박민영', 0, '2024-12-26', 'meeno2@by.kr', '미노이', 2),
	(523, '1234', '이민혁', 0, '2024-12-26', 'mh@by.kr', '이민혁', 0),
	(524, '1234', '민윤기', 0, '2024-12-26', 'min@by.kr', '슈가', 0),
	(525, '5918', '묘이 미나', 0, '2024-12-26', 'mina@by.kr', '미나', 0),
	(526, '1234', '김민규', 0, '2024-12-26', 'ming@by.kr', '민규', 0),
	(527, '1234', '최민호', 0, '2024-12-26', 'minho@by.kr', '민호', 0),
	(528, '1637', '김민정', 0, '2024-12-26', 'minj@by.kr', '윈터', 2),
	(529, '7577', '히라이 모모', 0, '2024-12-26', 'momo@by.kr', '모모', 0),
	(530, '1234', '성시경', 0, '2024-12-26', 'morning@music.com', '성시경', 2),
	(531, '1234', '김남진', 0, '2024-12-26', 'namjin@by.kr', '남진', 2),
	(532, '1234', '나훈아', 0, '2024-12-26', 'nhoon@by.kr', '나훈아', 2),
	(533, '1234', '김형수', 0, '2024-12-26', 'night@music.com', '케이윌', 2),
	(534, '7321', '닝이줘', 0, '2024-12-26', 'ning@by.kr', '닝닝', 0),
	(535, '6180', 'NMIXX', 0, '2024-12-26', 'NMIXX@by.kr', 'NMIXX', 2),
	(536, '1415', '임나연', 0, '2024-12-26', 'ny@by.kr', '나연', 0),
	(537, '4654', '오해원', 0, '2024-12-26', 'ohw@by.kr', '해원', 0),
	(538, '1234', '이진기', 0, '2024-12-26', 'onew@by.kr', '온유', 0),
	(539, '1234', '임슬옹', 0, '2024-12-26', 'oong@by.kr', '임슬옹', 0),
	(540, '1234', '김현우', 0, '2024-12-26', 'owen@by.kr', '오왼', 2),
	(541, '1234', '박지민', 0, '2024-12-26', 'parkji@by.kr', '지민', 0),
	(542, '1234', '신동근', 0, '2024-12-26', 'peniel@by.kr', '프니엘', 0),
	(543, '1234', '김원필', 0, '2024-12-26', 'pil@by.kr', '원필', 0),
	(544, '1234', '조용필', 0, '2024-12-26', 'quiet@by.kr', '조용필', 2),
	(545, '1234', '김남석', 0, '2024-12-26', 'rapm@by.kr', 'RM', 0),
	(546, '6430', 'Red Velvet', 0, '2024-12-26', 'RedVelvet@by.kr', 'Red Velvet', 2),
	(547, '7107', '나오이 레이', 0, '2024-12-26', 'rei@by.kr', '레이', 0),
	(548, '1234', '한경일', 0, '2024-12-26', 'river@music.com', '한경일', 2),
	(549, '1234', '소재훈', 0, '2024-12-26', 'RMuseum@by.kr', 'Rad Museum', 2),
	(550, '1234', '길성준', 0, '2024-12-26', 'road@by.kr', '길', 0),
	(551, '1234', '노연정', 0, '2024-12-26', 'rockStar@by.kr', '연정', 2),
	(552, '1908', '박채영', 0, '2024-12-26', 'rose@by.kr', '로제', 0),
	(553, '6346', '신류진', 0, '2024-12-26', 'ryu@by.kr', '류진', 0),
	(554, '1891', '미나토자키 사나', 0, '2024-12-26', 'sana@by.kr', '사나', 0),
	(555, '1234', '수와 진', 0, '2024-12-26', 'sandj@by.kr', '수와 진', 2),
	(556, '1234', '안상진', 0, '2024-12-26', 'sangjin@by.kr', '진', 0),
	(557, '1234', '안상수', 0, '2024-12-26', 'sangsu@by.kr', '수', 0),
	(558, '1234', '임재현', 0, '2024-12-26', 'sea@music.com', '임재현', 2),
	(559, '7204', '서주현', 0, '2024-12-26', 'seoj@by.kr', '서현', 0),
	(560, '1234', '서은광', 0, '2024-12-26', 'seo@by.kr', '서은광', 0),
	(561, '3163', '강슬기', 0, '2024-12-26', 'seul@by.kr', '슬기', 0),
	(562, '1234', '오세훈', 0, '2024-12-26', 'sh@by.kr', '세훈', 0),
	(563, '1234', '블랙핑크',0,'2024-12-26', 'sh@by.kr', '세훈', 2);

-- 테이블 beyondcloud.nowplaylist 구조 내보내기
CREATE TABLE IF NOT EXISTS `nowplaylist` (
  `nowPlayList_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `member_id` bigint(20) NOT NULL,
  `sequence` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`nowPlayList_id`),
  KEY `FK_Member_TO_NowPlayList_1` (`member_id`),
  CONSTRAINT `FK_Member_TO_NowPlayList_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.nowplaylist:~0 rows (대략적) 내보내기
DELETE FROM `nowplaylist`;

-- 테이블 beyondcloud.playlist 구조 내보내기
CREATE TABLE IF NOT EXISTS `playlist` (
  `playList_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `isPublic` tinyint(1) NOT NULL,
  `reg_date` date NOT NULL DEFAULT curdate(),
  `member_id` bigint(20) NOT NULL,
  PRIMARY KEY (`playList_id`),
  KEY `FK_Member_TO_PlayList_1` (`member_id`),
  CONSTRAINT `FK_Member_TO_PlayList_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.playlist:~0 rows (대략적) 내보내기
DELETE FROM `playlist`;

-- 테이블 beyondcloud.role 구조 내보내기
CREATE TABLE IF NOT EXISTS `role` (
  `role_code` int(11) NOT NULL,
  `name` varchar(10) NOT NULL,
  PRIMARY KEY (`role_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.role:~3 rows (대략적) 내보내기
DELETE FROM `role`;
INSERT INTO `role` (`role_code`, `name`) VALUES
	(0, 'user'),
	(1, 'admin'),
	(2, 'artist');

-- 테이블 beyondcloud.song 구조 내보내기
CREATE TABLE IF NOT EXISTS `song` (
  `song_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `genre` varchar(10) NOT NULL,
  `Streaming_cnt` int(11) NOT NULL DEFAULT 0,
  `album_id` bigint(20) NOT NULL,
  `length` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`song_id`),
  KEY `FK_Album_TO_Song_1` (`album_id`),
  CONSTRAINT `FK_Album_TO_Song_1` FOREIGN KEY (`album_id`) REFERENCES `album` (`album_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.song:~0 rows (대략적) 내보내기
DELETE FROM `song`;

-- 테이블 beyondcloud.song_in_chart 구조 내보내기
CREATE TABLE IF NOT EXISTS `song_in_chart` (
  `sic_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `chart_id` bigint(20) NOT NULL,
  `song_id` bigint(20) NOT NULL,
  PRIMARY KEY (`sic_id`),
  KEY `FK_Chart_TO_Song_In_Chart_1` (`chart_id`),
  KEY `FK_Song_TO_Song_In_Chart_1` (`song_id`),
  CONSTRAINT `FK_Chart_TO_Song_In_Chart_1` FOREIGN KEY (`chart_id`) REFERENCES `chart` (`chart_id`),
  CONSTRAINT `FK_Song_TO_Song_In_Chart_1` FOREIGN KEY (`song_id`) REFERENCES `song` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.song_in_chart:~0 rows (대략적) 내보내기
DELETE FROM `song_in_chart`;

-- 테이블 beyondcloud.song_in_nowplaylist 구조 내보내기
CREATE TABLE IF NOT EXISTS `song_in_nowplaylist` (
  `sin_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `nowPlayList_id` bigint(20) NOT NULL,
  `song_id` bigint(20) NOT NULL,
  PRIMARY KEY (`sin_id`),
  KEY `FK_NowPlayList_TO_Song_In_NowPlayList_1` (`nowPlayList_id`),
  KEY `FK_Song_TO_Song_In_NowPlayList_1` (`song_id`),
  CONSTRAINT `FK_NowPlayList_TO_Song_In_NowPlayList_1` FOREIGN KEY (`nowPlayList_id`) REFERENCES `nowplaylist` (`nowPlayList_id`),
  CONSTRAINT `FK_Song_TO_Song_In_NowPlayList_1` FOREIGN KEY (`song_id`) REFERENCES `song` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.song_in_nowplaylist:~0 rows (대략적) 내보내기
DELETE FROM `song_in_nowplaylist`;

-- 테이블 beyondcloud.song_in_playlist 구조 내보내기
CREATE TABLE IF NOT EXISTS `song_in_playlist` (
  `sip_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `playList_id` bigint(20) NOT NULL,
  `song_id` bigint(20) NOT NULL,
  PRIMARY KEY (`sip_id`),
  KEY `FK_PlayList_TO_Song_In_Playlist_1` (`playList_id`),
  KEY `FK_Song_TO_Song_In_Playlist_1` (`song_id`),
  CONSTRAINT `FK_PlayList_TO_Song_In_Playlist_1` FOREIGN KEY (`playList_id`) REFERENCES `playlist` (`playList_id`),
  CONSTRAINT `FK_Song_TO_Song_In_Playlist_1` FOREIGN KEY (`song_id`) REFERENCES `song` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.song_in_playlist:~0 rows (대략적) 내보내기
DELETE FROM `song_in_playlist`;

-- 테이블 beyondcloud.streaming_count_by_member 구조 내보내기
CREATE TABLE IF NOT EXISTS `streaming_count_by_member` (
  `Streaming_count` bigint(20) NOT NULL AUTO_INCREMENT,
  `member_id` bigint(20) NOT NULL,
  `song_id` bigint(20) NOT NULL,
  `Streaming_dateTime` date NOT NULL DEFAULT curdate(),
  PRIMARY KEY (`Streaming_count`),
  KEY `FK_Member_TO_Streaming_count_by_member_1` (`member_id`),
  KEY `FK_Song_TO_Streaming_count_by_member_1` (`song_id`),
  CONSTRAINT `FK_Member_TO_Streaming_count_by_member_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  CONSTRAINT `FK_Song_TO_Streaming_count_by_member_1` FOREIGN KEY (`song_id`) REFERENCES `song` (`song_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 테이블 데이터 beyondcloud.streaming_count_by_member:~0 rows (대략적) 내보내기
DELETE FROM `streaming_count_by_member`;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

INSERT INTO album(name, member_id) VALUES 
('AD MARE', 535),
('ENTWURF', 535),
('expergo', 535),
('A Midsummer NMIXX\'s Dream', 535),
('Sonar (Breaker)', 535),
('Fe304: STICK OUT', 535),
('IT\'z Different', 481),
('IT\'z ICY', 481),
('IT\'z ME', 481),
('CHECKMATE', 481),
('THE STORY BEGINS', 397),
('PAGE TWO', 397),
('Feel Special', 397),
('Merry & Happy', 397),
('Summer Night', 397),
('다시만난세계 (Into The New World)', 376),
('소원을 말해봐 Gennie - The Second Mini Album', 376),
('Gee - The First Mini Album', 376),
('The Boys - The 3rd Album', 376),
('I GOT A BOY - The 4th Album', 376),
('Lion Heart - The 5th Album', 376),
('Run Devil Run - The 2nd Album Repackage', 376),
('훗 Hoot - The 3rd Mini Album', 376),
('FOREVER 1 - The 7th Album', 376),
('행복 Happiness', 546),
('Summer Magic', 546),
('Russian Roulette - The 3rd Mini Album', 546),
('Chill Kill - The 3rd Album', 546),
('The ReVe Festival 2022 - Feel My Rhythm\'', 546),
('The Perfect Red Velvet (Repackage)', 546),
('The ReVe Festival: Finale', 546),
('Whiplash - The 5th Mini Album', 430),
('Next Level', 430),
('Better Things', 430),
('SYNK : PARALLEL LINE - Special Digital Single', 430),
('Whiplash - The 5th Mini Album', 430),
('MY WORLD - The 3rd Mini Album', 430),
('Savage - The 1st Mini Album', 430),
('LOVE DIVE', 483),
('I\'VE MINE', 483),
('Supernova Love', 483),
('IVE SWITCH', 483),
('After LIKE', 483),
('Pink Tape - f(x) The 2nd Album', 466),
('4 Walls - The 4th Album', 466),
('Electric Shock - The 2nd Mini Album', 466),
('라차타 LA chA TA', 466),
('BORN PINK', 563),
('THE ALBUM', 563),
('SEVENTEEN 1ST ALBUM [FIRST ‘LOVE&LETTER’]', 389),
('Love&Letter Repackage Album', 389),
('SEVENTEEN 10th Mini Album ‘FML\'', 389),
('SEVENTEEN BEST ALBUM ‘17 IS RIGHT HERE\'', 389),
('SEVENTEEN 4th Album \'Face the Sun\'', 389),
('SEVENTEEN 12th Mini Album ‘SPILL THE FEELS\'', 389),
('Fourever', 454),
('The Book of Us : Gravity', 454),
('Every DAY6 February', 454),
('DAYDREAM', 454),
('Remember Us : Youth Part 2', 454),
('Band Aid', 454),
('TWS 1st Mini Album ‘Sparkling Blue’', 399),
('TWS 2nd Mini Album ‘SUMMER BEAT!’', 399),
('TWS 1st Single ‘Last Bell\'', 399),
('Brother Act.', 443),
('THIS IS US', 443),
('NEW MEN', 443),
('HOUR MOMENT', 443),
('I Mean', 443),
('꿈의 장: MAGIC', 400),
('별의 장: SANCTUARY', 400),
('minisode 3: TOMORROW', 400),
('이름의 장: TEMPTATION', 400),
('꿈의 장: STAR', 400),
('겨울 스페셜 앨범 \'12월의 기적 (Miracles In December)\'', 464),
('DON\'T MESS UP MY TEMPO - The 5th Album', 464),
('LOVE ME RIGHT - The 2nd Album Repackage', 464),
('The 1st Album \'XOXO\' Repackage', 464),
('LOVE SHOT - The 5th Album Repackage', 464),
('EX\'ACT - The 3rd Album', 464),
('MADE', 438),
('A', 438),
('빅뱅 미니앨범 5집 \'ALIVE\'', 438),
('Stand Up (2008 빅뱅 3rd Mini Album)', 438),
('Always', 438),
('Hot Issue', 438),
('Dynamite (DayTime Version)', 444),
('MAP OF THE SOUL : PERSONA', 444),
('YOU NEVER WALK ALONE', 444),
('LOVE YOURSELF  \'Her\'', 444),
('화양연화 Young Forever', 444),
('WINGS', 444),
('Odd - The 4th Album', 371),
('2009, Year Of Us', 371),
('The 2nd Album \'Lucifer\'', 371),
('누난 너무 예뻐 (Replay)', 371),
('ROMEO\' The Second Mini Album', 371),
('사랑을 사람으로 그린다면', 551),
('눈에 보이지 않는 노래는', 551),
('집', 473),
('이상비행', 473),
('입춘', 473),
('비틀비틀 짝짜꿍', 473),
('정류장', 473),
('HOWEVER', 474),
('201 (Special Edition)', 440),
('또 오해영 OST Part 7', 440),
('EVERYTHING', 440),
('Hollywood', 440),
('유미의 세포들 OST Part 3', 440),
('내 고향 서울엔', 440),
('Unplugged', 514),
('AsuRaBalBalTa', 514),
('Trip', 512),
('인생은 한번이야', 512),
('거리에서 (feat. ASH ISLAND)', 512),
('HOMESICK', 549),
('Band Of Dynamic Brothers', 462),
('우리집 고양이 츄르를 좋아해', 522),
('DA DA!', 522),
('DOPEBOii', 373),
('Archiive', 373),
('KING LOOPY', 520),
('Boyhood', 508),
('돈 벌 시간 2', 508),
('Smile', 540),
('City', 540),
('사랑과 추억', 532),
('지갑이 형님', 378),
('모정의 노래', 544),
('바람처럼 하늘처럼', 484),
('슬픈 사랑의 노래', 432),
('다섯 번 째 이야기', 555),
('목포 노래 큰 잔치', 531),
('주현미 30th Anniversary album', 495),
('FORM', 422),
('연가', 467),
('IM HERO', 475);

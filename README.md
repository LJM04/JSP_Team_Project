## query

CREATE TABLE saves (  
 id INT AUTO_INCREMENT PRIMARY KEY,  
 link VARCHAR(255) NOT NULL UNIQUE,  
 title VARCHAR(255) NOT NULL,  
 description TEXT,  
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  
);
  
-- 가상 컬럼 생성 (URL에서 docId 자동 추출 및 저장)  
-- ( REGEXP_SUBSTR() : 원본 문자열에서 "docId=[0-9]+" 를 추출함 )  
ALTER TABLE saves  
ADD COLUMN doc_id VARCHAR(50)  
GENERATED ALWAYS AS (REGEXP_SUBSTR(link, 'docId=[0-9]+')) STORED;  
  
-- 유니크 조건 추가 (중복 차단)
ALTER TABLE saves ADD UNIQUE (doc_id);  
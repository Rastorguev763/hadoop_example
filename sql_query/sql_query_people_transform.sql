-- Создаем таблицу
CREATE TABLE people_transform (
  Index INT,
  User_Id STRING,
  First_Name STRING,
  Last_Name STRING,
  Sex STRING,
  Email STRING,
  Phone STRING,
  Date_of_birth DATE,
  Job_Title STRING,
  Groupe INT
)
CLUSTERED BY (Groupe) INTO 10 BUCKETS
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
TBLPROPERTIES ('skip.header.line.count'='1');

-- Создаем промежуточную таблицу
CREATE TABLE intermediate_people_transform (
  Index INT,
  User_Id STRING,
  First_Name STRING,
  Last_Name STRING,
  Sex STRING,
  Email STRING,
  Phone STRING,
  Date_of_birth DATE,
  Job_Title STRING,
  Groupe INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
TBLPROPERTIES ('skip.header.line.count'='1');

-- Загружаем данные в промежуточную таблицу
LOAD DATA INPATH '/user/admin/csv_files_transformed/people_transform.csv' INTO TABLE intermediate_people_transform;

-- Загружаем данные из промежуточной таблицы в бакетированную таблицу
INSERT INTO TABLE people_transform
SELECT * FROM intermediate_people_transform;

-- Удаляем промежуточную таблицу
DROP TABLE intermediate_people_transform;
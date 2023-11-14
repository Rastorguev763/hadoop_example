-- Создаем таблицу
CREATE TABLE organizations_transform (
  Index INT,
  Organization_Id STRING,
  Name STRING,
  Website STRING,
  Country STRING,
  Description STRING,
  Founded INT,
  Industry STRING,
  Number_of_employees INT,
  Groupe INT
)
CLUSTERED BY (Groupe) INTO 10 BUCKETS
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
TBLPROPERTIES ('skip.header.line.count'='1');

-- Создаем промежуточную таблицу
CREATE TABLE intermediate_organizations_transform (
  Index INT,
  Organization_Id STRING,
  Name STRING,
  Website STRING,
  Country STRING,
  Description STRING,
  Founded INT,
  Industry STRING,
  Number_of_employees INT,
  Groupe INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
TBLPROPERTIES ('skip.header.line.count'='1');


-- Загружаем данные в промежуточную таблицу
LOAD DATA INPATH '/user/admin/csv_files_transformed/organizations_transform.csv' INTO TABLE intermediate_organizations_transform;

-- Загружаем данные из промежуточной таблицы в бакетированную таблицу
INSERT INTO TABLE organizations_transform
SELECT * FROM intermediate_organizations_transform;

-- Удаляем промежуточную таблицу
DROP TABLE intermediate_organizations_transform;
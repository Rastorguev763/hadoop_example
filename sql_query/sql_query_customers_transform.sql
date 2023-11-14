-- Создаем таблицу
CREATE TABLE customers_transform(
    Index INT,
    Customer_Id STRING,
    First_Name STRING,
    Last_Name STRING,
    Company STRING,
    City STRING,
    Country STRING,
    Phone_1 STRING,
    Phone_2 STRING,
    Email STRING,
    Subscription_Date DATE,
    Website STRING,
    Groupe INT
)
PARTITIONED BY(Year_Subscription INT)
CLUSTERED BY(Groupe) INTO 10 BUCKETS
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Создаем промежуточную таблицу
CREATE TABLE intermediate_customers_transform(
    Index INT,
    Customer_Id STRING,
    First_Name STRING,
    Last_Name STRING,
    Company STRING,
    City STRING,
    Country STRING,
    Phone_1 STRING,
    Phone_2 STRING,
    Email STRING,
    Subscription_Date DATE,
    Website STRING,
    Groupe INT,
    Year_Subscription INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Загружаем данные в промежуточную таблицу
LOAD DATA INPATH '/user/admin/csv_files_transformed/customers_transform.csv' INTO TABLE intermediate_customers_transform;

-- Загружаем данные из промежуточной таблицы в бакетированную таблицу
FROM intermediate_customers_transform
INSERT OVERWRITE TABLE customers_transform
PARTITION(Year_Subscription = 2020)
SELECT
    Index,
    Customer_Id,
    First_Name,
    Last_Name,
    Company,
    City,
    Country,
    Phone_1,
    Phone_2,
    Email,
    Subscription_Date,
    Website,
    Groupe
WHERE Year_Subscription = 2020;

FROM intermediate_customers_transform
INSERT OVERWRITE TABLE customers
PARTITION(Year_Subscription = 2021)
SELECT 
 Index,
    Customer_Id,
    First_Name,
    Last_Name,
    Company,
    City,
    Country,
    Phone_1,
    Phone_2,
    Email,
    Subscription_Date,
    Website,
    Groupe
WHERE Year_Subscription = 2021;

FROM intermediate_customers_transform
INSERT OVERWRITE TABLE customers
PARTITION(Year_Subscription = 2022)
SELECT 
Index,
    Customer_Id,
    First_Name,
    Last_Name,
    Company,
    City,
    Country,
    Phone_1,
    Phone_2,
    Email,
    Subscription_Date,
    Website,
    Groupe
WHERE Year_Subscription = 2022;

-- Удаляем промежуточную таблицу
DROP TABLE intermediate_customers_transform;
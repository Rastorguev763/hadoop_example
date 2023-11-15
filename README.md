# HADOOP

Инструкция по установке Docker на Windows <https://github.com/Rastorguev763/docker_example>

Установка Hadoop:

В заранее созданной папке выполняем последовательно команды

```
git clone https://github.com/tech4242/docker-hadoop-hive-parquet.git
```

```
cmd docker-hadoop-hive-parquet
```

```
docker-compose up
```

Как только образ собран, а контейнер поднят — заходим по <http://localhost:8888/hue> и попадаем в HUE. Придумываем произвольную пару логина-пароля для будущей авторизации и приступаем к работе

В интерфейсе hue переходим в раздел «files»

Это личная папка в файловой системе hadoop(hdfs).

Скачиваем все доступные тома произведения «Война и мир» Л.Н. Толстого: <https://all-the-books.ru/authors/tolstoy-lev-nikolaevich/>.

Далее подключаемся к контейнеру «datanode-1», создаем внутри папку и переносим в нее скачанные файлы. Файлы предварительно «схлопываем» в один.

Команда подлючения к контейнеру datanode-1

```bash
docker exec -it <имя контейнера datanode-1> /bin/bash
```

Команда для объединения файлов в один.

```bash
cat *.txt >> all.txt
```

Загружаем полученный файл на hdfs в вашу личную папку.

Перед загразкой в HDFS, нужно скопировать файл в контейнер

```bash
docker cp .\tolstoy\all_voyna-i-mir-tom-1.txt docker-hadoop-hive-parquet-datanode-1:example_folder
```

где:

***.\tolstoy\all_voyna-i-mir-tom-1.txt*** - ссылка на файл на локальной машине где запущен контейнер

***docker-hadoop-hive-parquet-datanode-1*** - имя контейнера

***example_folder*** - ссылка в контейнере на папку куда будет копироваться файл

После загрузки, выполняем команды внутри контейнера **datanode-1** где создадим новую папку в нашем HDFS

```bash
hadoop fs -mkdir /user/admin/tolstoy_vim
```

где:

***/user/admin/tolstoy_vim*** - ссылка на вашу папку в HDFS

***admin*** - имя пользователя которого создали при первом запуске HUE

После мы можем загрузить наш файл на HDFS командой

```bash
hadoop fs -put example_folder/all_voyna-i-mir-tom-1.txt  /user/admin/tolstoy_vim
```

где:

***example_folder/all_voyna-i-mir-tom-1.txt*** - ссылка на файл в контейнере datanode-1

***/user/admin/tolstoy_vim*** - ссылка на папку в нашей HDFS

Если все пройдет удачно, то по возвращению в hue видим полное произведение «Война и мир» на hdfs (не забудьте обновить страницу).

## Задание 1

Возвращаемся в терминал и продолжаем изучать hdfs — попробуйте выполнить команду, которая выводит содержимое вашей личной папки.
Команды выполняем внутри контейнера datanode-1.

```bash
hadoop fs -ls /user/admin/tolstoy_vim
```

*вывод*

```
Found 1 items
-rw-r--r--   3 root admin    6096018 2023-11-13 13:00 /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
```

Обратите внимание на права доступа к вашим файлам — их явно недостаточно, если вы решите поделиться столь важной книгой с вашим коллегой — давайте изменим права доступа к нашему файлу. Установите режим доступа, который дает полный доступ для владельца файла, а для сторонних пользователей возможность читать и выполнять.

```bash
hadoop fs -chmod 755 /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
```

Попробуйте заново использовать команду для вывода содержимого папки и обратите внимание как изменились права доступа к файлу.

*вывод*

```
root@fa4e46be28a0:/# hadoop fs -ls /user/admin/tolstoy_vim
Found 1 items
-rwxr-xr-x   3 root admin    6096018 2023-11-13 13:00 /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
```

Теперь попробуем вывести на экран информацию о том, сколько места на диске занимает наш файл. Желательно, чтобы размер файла был удобочитаемым.

```bash
hadoop fs -du -h /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
```

*вывод*

```
root@fa4e46be28a0:/# hadoop fs -du -h /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
5.8 M  /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
```

```bash
hadoop fs -stat "%r %b" /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
```

*вывод*

```
root@fa4e46be28a0:/# hadoop fs -stat "%r %b" /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
3 6096018
```

На экране вы можете заметить 2 числа. Первое число — это фактический размер файла, а второе — это занимаемое файлом место на диске с учетом репликации — измените фактор репликации на 2.

```bash
hadoop fs -setrep -R 2 /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
```

Повторите команду, которая выводит информацию о том, какое место на диске занимает файл и убедитесь, что изменения произошли.

```
root@fa4e46be28a0:/# hadoop fs -setrep -R 2 /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
Replication 2 set: /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt

root@fa4e46be28a0:/# hadoop fs -stat "%r %b" /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt
2 6096018
```

И финальное — напишите команду, которая подсчитывает количество строк в произведении «Война и мир».

```bash
hadoop fs -cat /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt | wc -l
```

*вывод*

```
root@fa4e46be28a0:/# hadoop fs -cat /user/admin/tolstoy_vim/all_voyna-i-mir-tom-1.txt | wc -l
10272
```

В качестве результатов вашей работы запишите ваши команды и вывод этих команд.

## Задание 2

Двигаемся дальше, и теперь на очереди — Hive!

Первым делом нужно достать данные в папке **csv_files**

Эти файлы будут подвержены анализу, но в них кое-чего не достает — добавьте в каждый файл столбец с номером группы таким образом, чтобы файл был разделен на 10 групп. В файл ***customers.csv*** добавьте столбец с номером года, в который была совершена подписка (Subscription Date). Используйте средства python + pandas.

Для преобразования запустить ***transformed_csv.py***

Загрузите полученные файлы на hdfs.

- Выполняем команды из 1-й части задания.

```bash
docker cp .\csv_files_transformed docker-hadoop-hive-parquet-datanode-1:example_folder
```

```bash
hadoop fs -put example_folder/csv_files_transformed  /user/admin/
```

Теперь ваша задача следующая: аналитики хотят сводную статистику на уровне каждой компании и на уровне каждого года получить целевую возрастную группу подписчиков — то есть, возрастную группу, представители которой чаще всего совершали подписку именно в текущий год на текущую компанию.

Например:

|Company|Year|Age_group|
|-------|----|---------|
|Apple|2023|0-18|
|Xiaomi|2023|25-35|

Все операции необходимо выполнить в Hive. Работать с Hive можно через интерфейс HUE, если перейти в раздел «Query», или выбрав нужный пункт в разделе «Editor».

Таким образом вам нужно создать под каждый csv-файл отдельную таблицу. Для оптимизации используйте свои знания партиционирования и бакетирования. А затем на основе 3-х таблиц собрать витрину, которая решает поставленную задачу. В качестве результата предоставьте код SQL-запросов для создания исходных таблиц и создания итоговой витрины.

В качестве результата необходимо предоставить:

- скрипты на python+pandas для предобработки исходных файлов

- код загрузки файлов на hdfs

- код всех запросов для создания таблиц и план запроса для формирования витрины.

## Python

```python
import os
import pandas as pd

def find_csv_files(folder_path):
    csv_files = []
    
    # Проверяем, существует ли указанная папка
    if not os.path.exists(folder_path):
        print(f"Папка {folder_path} не существует.")
        return csv_files

    # Обходим все файлы и подпапки в указанной папке
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            # Проверяем, является ли текущий файл CSV файлом
            if file.endswith(".csv"):
                # Формируем полный путь к файлу и добавляем его в список
                csv_files.append(os.path.join(root, file))
    
    return csv_files

def read_csv_file(file_path):
    try:
        # Используем функцию read_csv для чтения CSV файла
        dataframe = pd.read_csv(file_path)
        return dataframe
    except Exception as e:
        print(f"Произошла ошибка при чтении файла {file_path}: {e}")
        return None
    
def split_and_add_group(dataframe, num_parts=10):
    try:
        # Рассчитываем количество строк в каждой части
        rows_per_part = len(dataframe) // num_parts

        # Добавление номера части в столбец "groupe" к каждой части
        for i in range(num_parts):
            start_idx = i * rows_per_part
            end_idx = (i + 1) * rows_per_part if i < num_parts - 1 else None
            dataframe.loc[start_idx:end_idx, 'Groupe'] = f'{i + 1}'

        return dataframe
    except Exception as e:
        print(f"Произошла ошибка: {e}")
        return None

def save_to_csv(dataframe, output_file):
    try:
        # Получаем директорию из полного пути к файлу
        output_directory = os.path.dirname(output_file)

        # Проверяем существование директории
        if not os.path.exists(output_directory):
            # Если директории не существует, создаем её
            os.makedirs(output_directory)

        # Сохранение DataFrame в новый CSV файл
        dataframe.to_csv(output_file, index=False)
        print(f"DataFrame успешно сохранен в {output_file}")
    except Exception as e:
        print(f"Произошла ошибка при сохранении файла: {e}")

# Функция для извлечения года из даты
def extract_year(date_string):
    return pd.to_datetime(date_string).year



folder_path = 'csv_files' # "/путь/к/папке/.csv"
output_folder_path = 'csv_files_transformed'
csv_files_list = find_csv_files(folder_path)

for csv_file in csv_files_list:
    filename = os.path.basename(csv_file).split('.')[0]+'_transform'+'.csv'
    path = output_folder_path + '/' + filename
    frame_csv = read_csv_file(csv_file)
    frame_csv = split_and_add_group(frame_csv, num_parts=10)
    if os.path.basename(csv_file) == 'customers.csv':
        # Добавление нового столбца "номер года"
        frame_csv['Year Subscription'] = frame_csv['Subscription Date'].apply(extract_year)
   
    save_to_csv(frame_csv, path)
```

## SQL Query

```sql
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
```

```sql
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
```

```sql
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
INSERT OVERWRITE TABLE customers_transform
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
INSERT OVERWRITE TABLE customers_transform
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
```

```sql
WITH ages AS
  ( SELECT org.Name AS company,
           cust.Year_Subscription AS YEAR,
           FLOOR(DATEDIFF((cust.Subscription_Date), DATE(ppl.Date_of_birth)) / 365) AS age,
           COUNT(*) AS subscribers_count,
           ROW_NUMBER() OVER (PARTITION BY org.Name, cust.Year_Subscription
                              ORDER BY COUNT(*) DESC) AS rn
   FROM organizations_transform AS org
   LEFT JOIN customers_transform AS cust ON org.Website = cust.Website
   JOIN people_transform AS ppl ON ppl.email = cust.email
   GROUP BY org.Name,
            cust.Year_Subscription,
            FLOOR(DATEDIFF((cust.Subscription_Date), DATE(ppl.Date_of_birth)) / 365))
SELECT company,
       YEAR,
       CASE
           WHEN age <= 18 THEN '[0 - 18]'
           WHEN age <= 25 THEN '[19 - 25]'
           WHEN age <= 35 THEN '[26 - 35]'
           WHEN age <= 45 THEN '[36 - 45]'
           WHEN age <= 55 THEN '[46 - 55]'
           ELSE '[55+]'
       END AS age_group
FROM ages
WHERE rn = 1
ORDER BY company,
         YEAR;
```

## План запроса

1. **Создание временной таблицы с данными:**
   - Используется конструкция `WITH` для создания временной таблицы `ages`, содержащей информацию о компаниях, годах подписки, возрасте подписчиков и их количестве.
   - Производится соединение таблиц `organizations_transform`, `customers_transform` и `people_transform` по заданным условиям.
   - Рассчитывается возраст подписчика на момент подписки с использованием функций `DATEDIFF` и `FLOOR`.
   - Данные агрегируются с использованием `GROUP BY` для каждой уникальной комбинации (компания, год подписки, возраст).
   - Оставляются только записи, где год подписки совпадает с годом в столбце `Subscription_Date`.
   - Присваиваются порядковые номера с использованием `ROW_NUMBER()` для каждой группы.

2. **Выбор первой возрастной группы для каждой уникальной комбинации:**
   - В основной части запроса выбираются название компании, год подписки, и определяется возрастная группа с использованием `CASE WHEN` в зависимости от значения возраста.
   - Результаты фильтруются, оставляя только те строки, где порядковый номер (`rn`) равен 1.
   - Результаты сортируются по названию компании и году подписки.

3. **Получение финальных результатов:**
   - Выполняется запрос для получения сводной статистики по возрастным группам подписчиков для каждой компании и года.
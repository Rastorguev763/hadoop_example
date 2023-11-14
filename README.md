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

скрипты на python+pandas для предобработки исходных файлов

код загрузки файлов на hdfs

код всех запросов для создания таблиц и план запроса для формирования витрины.

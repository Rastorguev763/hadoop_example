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


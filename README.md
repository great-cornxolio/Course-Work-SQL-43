# Course-Work-SQL-43

# Курсовая работа по модулю "SQL и получение данных"

## Задание

## Цели итоговой работы
Закрепить полученные знания и продемонстрировать умение применять подзапросы, соединения, функции и операторы sql.

## Описание задания
Для выполнения работы Вам необходимо:

1. Перейти по ссылке и ознакомиться с описанием базы данных: (https://edu.postgrespro.ru/bookings.pdf)
2. Подключиться к базе данных avia по одному из следующих вариантов:
-облачное подключение, те же настройки, что и у dvd-rental, только название базы demo, схема bookings
-импорт sql запроса из sql файла, представленных на 2 странице описания базы
-восстановить базу из .backup файла по ссылке avia
3. Оформить работу согласно “Приложения №1” в формате .pdf или .doc
-перелет, рейс = flight_id
4. Создать запросы, позволяющие ответить на вопросы из “Приложения №2”, решения должны быть приложены в формате .sql одним файлом
5. Отправить работу на проверку

## Критерии оценивания итоговой работы


*В облачной базе координаты находятся в столбце airports_data.coordinates - работаете, как с массивом. В локальной базе координаты находятся в столбцах airports.longitude и airports.latitude.
Кратчайшее расстояние между двумя точками A и B на земной поверхности (если принять ее за сферу) определяется зависимостью:
d = arccos {sin(latitude_a)·sin(latitude_b) + cos(latitude_a)·cos(latitude_b)·cos(longitude_a - longitude_b)}, где latitude_a и latitude_b — широты, longitude_a, longitude_b — долготы данных пунктов, d — расстояние между пунктами измеряется в радианах длиной дуги большого круга земного шара.
Расстояние между пунктами, измеряемое в километрах, определяется по формуле:
L = d·R, где R = 6371 км — средний радиус земного шара.

Итого: максимум 200 баллов.
Для зачета необходимо набрать минимум 130 баллов.

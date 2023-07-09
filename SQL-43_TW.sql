--=============== ИТОГОВАЯ РАБОТА С POSTGRESQL =======================================

SET search_path TO bookings;

--ЗАДАНИЕ №1
--В каких городах больше одного аэропорта?

select city, count(*) "number of airports"
from airports --выбираем колонку с названием города и результат функции для подсчета строк в группе из таблицы airports
group by city --группируем по названию города
having count(*) > 1 --при условии, что кол-во строк в группе больше 1

--ЗАДАНИЕ №2
--В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
--В решении обязательно должно быть использовано: подзапрос.

with cte as (
	select *
	from aircrafts
	where range = (select max(range) from aircrafts)) --создаем СТЕ и выбираем строку из таблицы aircrafts с самым большим значением дальности полета в этой таблице
select distinct ap.airport_code, ap.airport_name
from airports ap --выбираем уникальные колонки с кодом и названием аэропорта из таблицы airports
join flights fl on ap.airport_code = fl.departure_airport  --при условии, что аэропорт вылета - это аэропорт, где обслуживается самолет, соединяем запрос с таблицей flights по этим значениям
join cte using(aircraft_code) --присоединяем запрос к СТЕ по коду самолета

--ЗАДАНИЕ №3
--Вывести 10 рейсов с максимальным временем задержки вылета.
--В решении обязательно должно быть использовано: оператор LIMIT.

select flight_no, actual_departure - scheduled_departure delay 
from flights --выбираем номер рейса из таблицы flights, а во второй колонке считаем время задержки (разница между фактическим и планируемым временем вылета самолета)
where status in ('Departed', 'Arrived') --указываем условие по для тех рейсов, которые вылетели и находятся в полете либо прибыли в место назначения
order by delay desc --сортируем по убыванию значения задержки вылета
limit 10 --ограничиваем результат 10 строками

--ЗАДАНИЕ №4
--Были ли брони, по которым не были получены посадочные талоны?
--В решении обязательно должно быть использовано: верный тип JOIN.

select count(*) "number of bookings without BP" --считаем кол-во строк из запроса сt2 и находим кол-во броней, по которым не были получены посадочные
from (
	select distinct ct.book_ref --выбираем уникальные номера броней из подзапроса ct
	from (
		select t.ticket_no, b.book_ref
		from bookings b --выбираем номера билетов в соответствии с номером брони из таблицы bookings
		join tickets t using(book_ref)) ct --соединяем с таблицей tickets, заворачиваем в подзапрос ct готовую таблицу "номер билета - номер брони"
	left join boarding_passes bp using(ticket_no) --соединяем левым соединением с таблицей boarding_passes, чтобы увидеть пустые поля в колонке boarding_no в случае отсутствия посадочного
	where bp.boarding_no is null --фильтруем по пустым значениям в колонке boarding_no, чтобы вывести брони без посадочных
	) ct2
	
--ЗАДАНИЕ №5
--Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день.
--Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах в течении дня.
--В решении обязательно должно быть использовано: оконная функция; подзапросы или/и cte.

with cte1 as (  --создаем cte1, где выводим общее количество мест в самолете по каждому ID рейса
	select f.flight_id, f.departure_airport, f.actual_departure, count(*) total_seats
	from seats s --из таблицы seats выбираем кол-во строк, сгруппированных по ID рейса из таблицы flights
	join flights f using (aircraft_code) --присоединяем таблицу flights для вывода ID рейса по коду самолета
	group by 1
	having f.actual_departure is not null), --группируем по ID рейса и добавляем условие о наличии даты и времени вылета (по условию задачи)
     cte2 as ( --создаем cte2, где выводим количество мест, по которым были выданы посадочные, по каждому ID рейса
	select flight_id, count(*) occup_seats
	from boarding_passes --из таблицы boarding_passes выбираем кол-во строк, сгруппированных по ID рейса
	group by 1)
select 
	cte2.flight_id, --выбираем ID рейса
	(cte1.total_seats - cte2.occup_seats) num_free_seats, --считаем кол-во свободных мест, вычитая кол-во занятых мест в cte2 из общ. кол-ва мест в самолете в cte1
	round(100.0 * (cte1.total_seats - cte2.occup_seats) / cte1.total_seats, 2) percent_free_seats, --считаем эту разницу в процентном соотношении
	sum(cte2.occup_seats) over (partition by cte1.departure_airport, cte1.actual_departure::date order by cte1.actual_departure) sum_passengers --добавляем оконную функцию sum с накоплением для количества вылетевших пассажиров, группируя по аэропорту и дню вылета и сортируя по дате с временем вылета
from cte2
join cte1 using(flight_id) --соединяем обе cte
order by cte1.departure_airport, cte1.actual_departure --для визуальной видимости накопления сортируем по аэоропорту и дате

--ЗАДАНИЕ №6
--Найдите процентное соотношение перелетов по типам самолетов от общего количества.
--В решении обязательно должно быть использовано: подзапрос или окно; оператор ROUND.

select
	aircraft_code,
	round(100. * count(*) / (select count(*) from flights), 2) aircraft_percentage --считаем процентное соотношение между кол-вом рейсов по типу самолета и общим количеством рейсов, полученным через подзапрос; полученное значение округляем через ROUND
from flights
group by 1 --для расчета кол-ва рейсов по типу самолета, группируем по aircraft_code

--ЗАДАНИЕ №7
--Были ли города, в которые можно добраться бизнес-классом дешевле, чем эконом-классом в рамках перелета?
--В решении обязательно должно быть использовано: CTE.

with cte1 as (
	select flight_id, min(amount) "b_cost"
	from ticket_flights tf
	where fare_conditions = 'Business' 
	group by 1), --создаем CTE1, где выводим минимальную стоимость билета бизнес-класса, группируя по каждому рейсу
	 cte2 as (
	select flight_id, max(amount) "e_cost"
	from ticket_flights tf
	where fare_conditions = 'Economy' 
	group by 1) --создаем CTE2, где выводим максимальную стоимость билета эконом-класса, группируя по каждому рейсу
select distinct a.city --выводим уникальные названия городов, соединяя необходимые таблицы
from cte1 
join cte2 using(flight_id) --соединяем CTE1 и CTE2
join flights f using(flight_id)
join airports a on f.arrival_airport = a.airport_code --для вывода названия города соединяем сначала с таблицей flights, а потом с таблицей airports
where cte1.b_cost < cte2.e_cost --задаем условие, чтобы найти рейсы, где стоимость билета бизнес-класса будет меньше стоимости билета эконом-класса

--ЗАДАНИЕ №8
--Между какими городами нет прямых рейсов?
--В решении обязательно должно быть использовано:
-- - декартово произведение в предложении FROM;
-- - самостоятельно созданные представления (если облачное подключение, то без представления);
-- - оператор EXCEPT.

create view direct as --создаем представление, где создадим таблицу "город вылета - город прилета", не исключая тот факт, что прямой рейс между городами может быть только в одну сторону
	select distinct a1.city departure_city, a2.city arrival_city
	from airports a1, airports a2 --соединяем колонку city декартовым соединением
	where a1.city != a2.city --исключаем строки, где город вылета равен городу прилета
	order by 1, 2
	
select * from direct
except --вычитаем из представления direct таблицу с рейсами
select distinct a_d.city, a_a.city
from flights f -- из таблицы flight выбираем уникальные колонки с кодами аэропортов
join airports a_d on f.departure_airport = a_d.airport_code --соединяем с таблицей airports для идентификации города вылета
join airports a_a on f.arrival_airport = a_a.airport_code --соединяем с таблицей airports для идентификации города прилета

--ЗАДАНИЕ №9
--Вычислите расстояние между аэропортами, связанными прямыми рейсами,
--сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы.
--В решении обязательно должно быть использовано:
-- - оператор RADIANS или использование sind/cosd;
-- - CASE.

select distinct
	a_d.airport_name departure_airport, a_a.airport_name arrival_airport, --выбираем уникальные строки с названиями аэропортов 
	round(6371. * (acos(sin(radians(a_d.latitude)) * sin(radians(a_a.latitude)) + cos(radians(a_d.latitude)) * cos(radians(a_a.latitude)) * cos(radians(a_d.longitude - a_a.longitude))))::numeric, 2) distance_km, --считаем расстояние между аэропортами, испульзуя RADIANS для преобразования градусов в радианы и округляем до 2 знаков после запятой
	case
		when round(6371. * (acos(sin(radians(a_d.latitude)) * sin(radians(a_a.latitude)) + cos(radians(a_d.latitude)) * cos(radians(a_a.latitude)) * cos(radians(a_d.longitude - a_a.longitude))))::numeric, 2) > a.range
		then 'invalid model'
		else 'valid model'
	end aircraft_check -- используем case, чтобы сравнить расстояние между аэропортами с технической возможностью самолета
from flights f
join airports a_d on f.departure_airport = a_d.airport_code --соединяем с таблицей airports для идентификации аэропорта вылета
join airports a_a on f.arrival_airport = a_a.airport_code--соединяем с таблицей airports для идентификации аэропорта прилета
join aircrafts a using(aircraft_code) --соединяем с таблицей aircrafts для идентификации максимальной дальности полета самолета по каждому рейсу
where a_a.airport_name > a_d.airport_name --исключаем позиции между двумя аэропортами "в обратную сторону"
order by 1, 2 --сортируем для визульного удобства


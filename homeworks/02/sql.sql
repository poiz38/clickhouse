CREATE DATABASE nyc_taxi;

CREATE TABLE nyc_taxi.trips_small (
    trip_id             UInt32,
    pickup_datetime     DateTime,
    dropoff_datetime    DateTime,
    pickup_longitude    Nullable(Float64),
    pickup_latitude     Nullable(Float64),
    dropoff_longitude   Nullable(Float64),
    dropoff_latitude    Nullable(Float64),
    passenger_count     UInt8,
    trip_distance       Float32,
    fare_amount         Float32,
    extra               Float32,
    tip_amount          Float32,
    tolls_amount        Float32,
    total_amount        Float32,
    payment_type        Enum('CSH' = 1, 'CRE' = 2, 'NOC' = 3, 'DIS' = 4, 'UNK' = 5),
    pickup_ntaname      LowCardinality(String),
    dropoff_ntaname     LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (pickup_datetime, dropoff_datetime);


INSERT INTO nyc_taxi.trips_small
SELECT
    trip_id,
    pickup_datetime,
    dropoff_datetime,
    pickup_longitude,
    pickup_latitude,
    dropoff_longitude,
    dropoff_latitude,
    passenger_count,
    trip_distance,
    fare_amount,
    extra,
    tip_amount,
    tolls_amount,
    total_amount,
    payment_type,
    pickup_ntaname,
    dropoff_ntaname
FROM s3(
    'https://datasets-documentation.s3.eu-west-3.amazonaws.com/nyc-taxi/trips_{0..2}.gz',
    'TabSeparatedWithNames'
);


Посмотрим, сколько строк было вставлено:

SELECT count()
FROM nyc_taxi.trips_small;



Каждый TSV-файл содержит примерно 1 млн строк, а три файла в сумме — 3 000 317 строк. Давайте посмотрим на несколько строк:

SELECT *
FROM nyc_taxi.trips_small
LIMIT 10;



Обратите внимание, что есть столбцы с датами подачи и высадки пассажиров, геокоординатами, информацией о тарифе, районами Нью-Йорка и многим другим.

Давайте выполним несколько запросов. Этот запрос показывает 10 районов Нью-Йорка с наибольшим числом подач такси:

SELECT
   pickup_ntaname,
   count(*) AS count
FROM nyc_taxi.trips_small WHERE pickup_ntaname != ''
GROUP BY pickup_ntaname
ORDER BY count DESC
LIMIT 10;



Этот запрос показывает среднюю стоимость проезда в зависимости от количества пассажиров:

SELECT
   passenger_count,
   avg(total_amount)
FROM nyc_taxi.trips_small
WHERE passenger_count < 10
GROUP BY passenger_count;



Ниже показана зависимость между количеством пассажиров и расстоянием поездки:

SELECT
    passenger_count,
    avg(trip_distance) AS distance,
    count() AS c
FROM nyc_taxi.trips_small
GROUP BY passenger_count
ORDER BY passenger_count ASC


select count() from nyc_taxi.trips_small where payment_type = 1;
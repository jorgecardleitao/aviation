WITH airlines AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/airline.csv', header=true)
)

, routes AS (
    SELECT *,
    emissionflightinfo_passengerloadfactor * seatcount AS passengers,
    emissionflightinfo_flightdistancekm AS distance,
    emissionflightinfo_passengerloadfactor AS loadfactor,
    values_averageclass_co2withoutrfiperpassengerintons * emissionflightinfo_passengerloadfactor * seatcount AS co2,
    emissionflightinfo_passengerloadfactor * emissionflightinfo_flightdistancekm * seatcount AS pkm
    FROM read_csv_auto('data/flight_emission_data_2025-01-17/emissionV22_2025-02-24.csv', header=true)
)

, airports AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/airport.csv', header=true)
)

, aircraft_performance AS (
    SELECT
    aircraftiatacode AS aircraft,
    CASE aircraftiatacode
        WHEN '351' THEN 440
        WHEN '359' THEN 432
        WHEN '781' THEN 420
        WHEN '788' THEN 420
        WHEN '789' THEN 420
    END AS total_seats,
    regr_slope(values_averageclass_co2withoutrfiperpassengerintons, emissionflightinfo_flightdistancekm) as m,
    regr_intercept(values_averageclass_co2withoutrfiperpassengerintons, emissionflightinfo_flightdistancekm) as b,
    regr_r2(values_averageclass_co2withoutrfiperpassengerintons, emissionflightinfo_flightdistancekm) as r2,
FROM routes
WHERE total_seats is NOT NULL
GROUP BY aircraftiatacode
ORDER BY m
)

, "system" AS (
    SELECT
    SUM(passengers * frequency) AS passengers,
    SUM(passengers * frequency) / SUM(frequency) AS avg_passengers,
    SUM(distance * frequency) / SUM(frequency) AS avg_distance,
    SUM(frequency) AS count,
    SUM(emissionflightinfo_passengerloadfactor * frequency) / SUM(frequency) AS avg_loadfactor,
    SUM(seatcount * frequency) / SUM(frequency) AS avg_seats,
    SUM(co2 * frequency) AS co2,
    SUM(pkm * frequency) AS pkm,
    SUM(co2 * frequency) / SUM(pkm * frequency) * 1000 * 1000 AS gco2_pax_km,
    FROM routes
)

, scenarios AS (
(
    SELECT 
    'system' AS "approach",
    'real' AS "case",
    'all' AS aircraft,
    co2,
    pkm,
    gco2_pax_km,
    FROM "system"
)
UNION ALL
(
SELECT
    'system' AS "approach",
    'step1' AS "case",
    aircraft,
    SUM((b + m * avg_distance) * avg_passengers * count) AS co2,
    SUM(pkm),
    SUM((b + m * avg_distance) * avg_passengers * count / pkm) * 1000 * 1000 AS gco2_pax_km,
FROM aircraft_performance, system
GROUP BY aircraft, "case", "approach"
)
UNION ALL
(
SELECT
    'system' AS "approach",
    'step2' AS "case",
    aircraft,
    SUM((b + m * avg_distance) * avg_passengers * (avg_seats / (total_seats) * count)) AS co2,
    SUM(pkm),
    SUM((b + m * avg_distance) * avg_passengers * (avg_seats / (total_seats) * count) / pkm) * 1000 * 1000 AS gco2_pax_km,
FROM aircraft_performance, system
GROUP BY aircraft, "case", "approach"
)
UNION ALL
(
SELECT
    'system' AS "approach",
    'step3' AS "case",
    aircraft,
    SUM((b + m * avg_distance) * avg_passengers * (avg_seats * avg_loadfactor / (total_seats * 0.95) * count)) AS co2,
    SUM(pkm),
    SUM((b + m * avg_distance) * avg_passengers * (avg_seats * avg_loadfactor / (total_seats * 0.95) * count) / pkm) * 1000 * 1000 AS gco2_pax_km,
FROM aircraft_performance, system
GROUP BY aircraft, "case", "approach"
)
UNION ALL
(
SELECT
    'route' AS "approach",
    'step1' AS "case",
    aircraft,
    SUM(((b + m * distance)*passengers) * frequency) AS co2,
    SUM(pkm * frequency),
    SUM(((b + m * distance)*passengers) * frequency) / SUM(pkm * frequency) * 1000 * 1000 AS gco2_pax_km,
FROM aircraft_performance, routes
GROUP BY aircraft, "case", "approach"
)
UNION ALL
(
SELECT
    'route' AS "approach",
    'step2' AS "case",
    aircraft,
    SUM(((b + m * distance)*passengers) * (passengers / (total_seats * loadfactor) * frequency)) AS co2,
    SUM(pkm * frequency),
    SUM(((b + m * distance)*passengers) * (passengers / (total_seats * loadfactor) * frequency)) / SUM(pkm * frequency) * 1000 * 1000 AS gco2_pax_km,
FROM aircraft_performance, routes
GROUP BY aircraft, "case", "approach"
)
UNION ALL
(
SELECT
    'route' AS "approach",
    'step3' AS "case",
    aircraft,
    SUM(((b + m * distance)*passengers) * (passengers / (total_seats * 0.95)) * frequency) AS co2,
    SUM(pkm * frequency),
    SUM(((b + m * distance)*passengers) * (passengers / (total_seats * 0.95)) * frequency) / SUM(pkm * frequency) * 1000 * 1000 AS gco2_pax_km,
FROM aircraft_performance, routes
GROUP BY aircraft, "case", "approach"
)
)

SELECT * FROM scenarios
ORDER BY aircraft, "approach", "case"

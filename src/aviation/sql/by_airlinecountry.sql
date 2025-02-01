
WITH airlines AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/airline.csv', header=true)
)

, routes AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/emissionv22_2023.csv', header=true)
)

, airports AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/airport.csv', header=true)
)

, with_country AS (
    SELECT routes.*, airlines.country
    FROM routes
    LEFT JOIN airlines ON routes.airlineiatacode = airlines.iatacode
)

SELECT
    country,
    COUNT(DISTINCT aircraftiatacode) AS aircraft_types,
    SUM(emissionflightinfo_flightdistancekm * frequency) / SUM(frequency) AS avg_distance,
    SUM(emissionflightinfo_flightdistancekm * frequency) AS flown_distance,
    SUM(frequency) AS flights,
    SUM(emissionflightinfo_passengerloadfactor * seatcount * frequency) AS passengers,
    SUM(seatcount * frequency) AS seats,
    SUM(emissionflightinfo_passengerloadfactor * frequency) / SUM(frequency) AS average_load,
FROM with_country
GROUP BY country

ORDER BY passengers DESC

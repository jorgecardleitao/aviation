WITH airlines AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/airline.csv', header=true)
)

, routes AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/emissionv22_2023.csv', header=true)
)

, airports AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/airport.csv', header=true)
)

SELECT 
COUNT(*) AS count,
COUNT(DISTINCT (airlineiatacode, aircraftiatacode, emissionflightinfo_arrivaliatacode, emissionflightinfo_departureiatacode)) AS unique_routes,
COUNT(DISTINCT id)  AS unique_id,
FROM routes

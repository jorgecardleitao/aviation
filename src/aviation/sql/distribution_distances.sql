WITH airlines AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/airline.csv', header=true)
)

, routes AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/emissionV22_2025-02-24.csv', header=true)
)

, airports AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/airport.csv', header=true)
)

SELECT
    emissionflightinfo_departureiatacode,
    emissionflightinfo_arrivaliatacode,
    emissionflightinfo_flightdistancekm * frequency AS total_flown,
FROM routes
ORDER BY total_flown DESC
LIMIT 5

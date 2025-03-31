
WITH airlines AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/airline.csv', header=true)
)

, routes AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/emissionV22_2025-02-24.csv', header=true)
)

, airports AS (
    SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/airport.csv', header=true)
)

, efficiency AS (
    SELECT
        emissionflightinfo_departureiatacode as departure,
        emissionflightinfo_arrivaliatacode as arrival,
        airlinename,
        SUM(values_averageclass_co2withoutrfiperpassengerintons * frequency)
            / SUM(emissionflightinfo_flightdistancekm * frequency)
            * 1000 * 1000
        AS gco2_pax_km,
    FROM routes, airports as airports_a, airports as airports_d
    WHERE
        airports_d.iatacode = emissionflightinfo_departureiatacode AND
        airports_a.iatacode = emissionflightinfo_arrivaliatacode
    GROUP BY departure, arrival, airlinename
)

, most_efficient AS (
    SELECT * FROM efficiency
    ORDER BY gco2_pax_km ASC
    LIMIT 5
)

, least_efficient AS (
    SELECT * FROM efficiency
    ORDER BY gco2_pax_km DESC
    LIMIT 5
)

SELECT * FROM most_efficient
UNION ALL
SELECT * FROM least_efficient

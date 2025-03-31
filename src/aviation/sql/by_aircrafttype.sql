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
    aircraftiatacode,
    COUNT(DISTINCT airlinename) AS airlines,
    SUM(emissionflightinfo_flightdistancekm * frequency) / SUM(frequency) AS avg_distance,
    SUM(emissionflightinfo_flightdistancekm * frequency) AS flown_distance,
    SUM(emissionflightinfo_greatcircledistancekm * frequency) AS gcd,
    SUM(frequency) AS flights,
    SUM(emissionflightinfo_passengerloadfactor * seatcount * frequency) AS passengers,
    SUM(seatcount * frequency) AS seats,
    SUM(emissionflightinfo_passengerloadfactor * frequency) / SUM(frequency) AS average_load,
    SUM(values_averageclass_co2withoutrfiperpassengerintons * frequency * emissionflightinfo_passengerloadfactor * seatcount) AS co2,
    SUM(values_averageclass_co2withoutrfiperpassengerintons * frequency)
        / SUM(emissionflightinfo_flightdistancekm * frequency)
        * 1000 * 1000
    AS gco2_pax_km,
FROM routes
GROUP BY aircraftiatacode
ORDER BY passengers DESC

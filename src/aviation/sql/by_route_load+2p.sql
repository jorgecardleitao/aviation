
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
    emissionflightinfo_departureiatacode as departure,
    emissionflightinfo_arrivaliatacode as arrival,
    FIRST(airports_a.longitude) as arrival_longitude,
    FIRST(airports_a.latitude) as arrival_latitude,
    FIRST(airports_d.longitude) as departure_longitude,
    FIRST(airports_d.latitude) as departure_latitude,
    COUNT(DISTINCT aircraftiatacode) AS aircraft_types,
    COUNT(DISTINCT airlinename) AS airlines,
    SUM(emissionflightinfo_flightdistancekm * frequency) / SUM(frequency) AS avg_distance,
    SUM(emissionflightinfo_flightdistancekm * frequency) AS flown_distance,
    SUM(emissionflightinfo_greatcircledistancekm * frequency) AS gcd,
    SUM(frequency) AS flights,
    SUM(LEAST(emissionflightinfo_passengerloadfactor+0.02, 1) * seatcount * frequency) AS passengers,
    SUM(seatcount * frequency) AS seats,
    SUM(LEAST(emissionflightinfo_passengerloadfactor+0.02, 1) * frequency) / SUM(frequency) AS average_load,
    SUM(values_averageclass_co2withoutrfiperpassengerintons * frequency * LEAST(emissionflightinfo_passengerloadfactor + 0.02, 1) * seatcount) AS co2,
    SUM(values_averageclass_co2withoutrfiperpassengerintons / emissionflightinfo_flightdistancekm * frequency)
        / SUM(frequency)
        * 1000 * 1000
    AS gco2_pax_km,
FROM routes, airports as airports_a, airports as airports_d
WHERE
    airports_d.iatacode = emissionflightinfo_departureiatacode AND
    airports_a.iatacode = emissionflightinfo_arrivaliatacode
GROUP BY departure, arrival
ORDER BY passengers DESC

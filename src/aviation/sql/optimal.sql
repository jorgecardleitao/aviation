
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
        frequency,
        frequency * emissionflightinfo_passengerloadfactor * seatcount AS passengers,
        emissionflightinfo_flightdistancekm as flown_distance,
        values_averageclass_co2withoutrfiperpassengerintons * frequency * emissionflightinfo_passengerloadfactor * seatcount AS co2,
        values_averageclass_co2withoutrfiperpassengerintons / emissionflightinfo_flightdistancekm * 1000 * 1000
        AS gco2_pax_km,
    FROM routes
)

, route_efficiency AS (
    SELECT
        departure,
        arrival,
        airlinename,
        SUM(frequency) AS frequency,
        SUM(gco2_pax_km * frequency) / SUM(frequency) AS gco2_pax_km,
    FROM efficiency
    GROUP BY departure, arrival, airlinename
)

, most_efficient AS (
    SELECT departure,
    arrival,
    MIN(gco2_pax_km) AS gco2_pax_km
    FROM route_efficiency
    GROUP BY departure, arrival
)

, optimal AS (
    SELECT
    efficiency.*,
    most_efficient.gco2_pax_km AS best_gco2_pax_km,
    FROM efficiency, most_efficient
    WHERE efficiency.departure = most_efficient.departure
        AND efficiency.arrival = most_efficient.arrival
)

SELECT
    SUM(gco2_pax_km * frequency) / SUM(frequency) AS gco2_pax_km,
    SUM(best_gco2_pax_km * frequency) / SUM(frequency) AS best_gco2_pax_km,
    SUM(co2) AS co2,
    SUM(best_gco2_pax_km/1000/1000 * passengers * flown_distance) AS best_co2,
FROM optimal

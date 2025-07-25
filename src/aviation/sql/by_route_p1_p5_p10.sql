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
    SUM(emissionflightinfo_passengerloadfactor * seatcount * frequency) AS passengers,
    SUM(values_averageclass_co2withoutrfiperpassengerintons * (emissionflightinfo_passengerloadfactor / emissionflightinfo_passengerloadfactor) * frequency * emissionflightinfo_passengerloadfactor * seatcount) AS co2,
    SUM(values_averageclass_co2withoutrfiperpassengerintons * (emissionflightinfo_passengerloadfactor / LEAST(emissionflightinfo_passengerloadfactor + 0.01)) * frequency * emissionflightinfo_passengerloadfactor * seatcount) AS co2_p1,
    SUM(values_averageclass_co2withoutrfiperpassengerintons * (emissionflightinfo_passengerloadfactor / LEAST(emissionflightinfo_passengerloadfactor + 0.05)) * frequency * emissionflightinfo_passengerloadfactor * seatcount) AS co2_p5,
    SUM(values_averageclass_co2withoutrfiperpassengerintons * (emissionflightinfo_passengerloadfactor / LEAST(emissionflightinfo_passengerloadfactor + 0.10)) * frequency * emissionflightinfo_passengerloadfactor * seatcount) AS co2_p10,
    SUM(values_averageclass_co2withoutrfiperpassengerintons / emissionflightinfo_flightdistancekm * frequency)
        / SUM(frequency)
        * 1000 * 1000
    AS gco2_pax_km,
    SUM(values_averageclass_co2withoutrfiperpassengerintons * (emissionflightinfo_passengerloadfactor / LEAST(emissionflightinfo_passengerloadfactor + 0.01)) / emissionflightinfo_flightdistancekm * frequency)
        / SUM(frequency)
        * 1000 * 1000
    AS gco2_p1_pax_km,
    SUM(values_averageclass_co2withoutrfiperpassengerintons * (emissionflightinfo_passengerloadfactor / LEAST(emissionflightinfo_passengerloadfactor + 0.05)) / emissionflightinfo_flightdistancekm * frequency)
        / SUM(frequency)
        * 1000 * 1000
    AS gco2_p5_pax_km,
    SUM(values_averageclass_co2withoutrfiperpassengerintons * (emissionflightinfo_passengerloadfactor / LEAST(emissionflightinfo_passengerloadfactor + 0.10)) / emissionflightinfo_flightdistancekm * frequency)
        / SUM(frequency)
        * 1000 * 1000
    AS gco2_p10_pax_km,
FROM routes, airports as airports_a, airports as airports_d
WHERE
    airports_d.iatacode = emissionflightinfo_departureiatacode AND
    airports_a.iatacode = emissionflightinfo_arrivaliatacode
GROUP BY departure, arrival
ORDER BY passengers DESC

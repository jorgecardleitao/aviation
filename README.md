# Air transport efficiency

This repository contains Python code to analyze and visualize route aviation data underlying

> Gössling, S, M Klöwer, JC Leitão, S Hirsch, D Brockenhagen, A Humpe, 2025. _Large emission avoidance potential in improved commercial air transport efficiency_, **Nature Communications Earth & Environment**, accepted.

Notebooks and plots are found in [/plots](https://github.com/jorgecardleitao/aviation/tree/main/plots),
data postprocessing is in [/src/aviation](https://github.com/jorgecardleitao/aviation/tree/main/src/aviation).

## Data

You need access to a secret key to access the raw data, see below.
Once you have it, you can run this code as shown below.

```bash
pip install hatch

export KEY=Yp...s
hatch run default:python src/aviation/main.py
```

NOTE: this will download the data to locally, under `data/` and output the results to directory `results`.
Both directories are git ignored.

## Run data checks

This repository contains a set of queries to assert data invariants, including invariants related to its comparison with
data observed by international organizations and airlines.

```bash
hatch run tests:run
```

## Available queries

You can find the list of queries in directory [`src/aviation/sql/`](./src/aviation/sql/).
Each of these queries is executed on GitHub's CI/CD and the results are available as artifacts in the job run.

## Raw data specification

## `emissionv22_2023.csv`

Each row is a unique (departure, arrival, aircraft type, airline), i.e. it contains aggregate information
about all the flights on a route (departure, arrival) for a given aircraft type and airline.

The data contains the following relevant columns:

* `id`: surrogate identifier of a (departure, arrival, aircraft type, airline)
* `airlineiatacode`: AITA code of the airline
* `frequency`: number of flights in the year
* `aircraftiatacode`: AITA code of the aircraft type
* `aircraftname`: name of the aircraft
* `seatcount`: number of seats of the aircraft type
* `values_averageclass_co2withoutrfiperpassengerintons`
* `emissionflightinfo_passengerloadfactor`: average load factor of passagers (this times seatcount is the total number of passagers)

# aviation

This repository contains Python code to analyze route aviation data.
You need access to a secret key to access the raw data, see below.
Once you have it, you can run this code as shown below.

```bash
pip install hatch

export KEY=4s...Q
hatch run default:python src/aviation/main.py src/aviation/sql/unique_invariants.sql
```

NOTE: this will download the data to locally, under `data/`. This directory is ignored by git.

## Available queries

- [by airline](./src/aviation/sql/by_airline.sql)
- [by country of airline](./src/aviation/sql/by_airlinecountry.sql)
- [totals](./src/aviation/sql/total.sql)

## Raw data specification

## `emissionv22_2023.csv`

Each row is a unique (departure, arrival, aircraft type, airline), i.e. it contains aggregate information
about all the flights on a route (departure, arrival), for a given aircraft type, and airline.

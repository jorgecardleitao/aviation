import os
import zipfile
import sys

import requests
import duckdb


def _download_file(url: str, directory: str) -> str:
    local_filename = directory + url.split('/')[-1]

    if os.path.exists(local_filename):
        return local_filename

    # NOTE the stream=True parameter below
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(local_filename, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192): 
                # If you have chunk encoded response uncomment if
                # and set chunk_size parameter to None.
                #if chunk: 
                f.write(chunk)
    return local_filename


def _unzip(source: str, target: str):
    """unzips file"""
    if os.path.exists(target):
        return

    with zipfile.ZipFile(source, 'r') as zip_ref:
        zip_ref.extractall(target)


def ensure_data():
    URL = f"https://files.atmosfair.de/index.php/s/{os.environ['KEY']}/download/flight_emission_data_2025-01-17.zip"
    os.makedirs("data/", exist_ok=True)
    path = _download_file(URL, "data/")
    _unzip(path, "data/flight_emission_data_2025-01-17")


TABLES = {
    "by_airline": "by_airline.sql",
    "by_airlinecountry": "by_airlinecountry.sql",
    "by_aircrafttype": "by_aircrafttype.sql",
    "total": "total.sql",
    "by_route": "by_route.sql",
}


def main():
    ensure_data()

    # to run a single SQL, for testing
    sql = sys.argv[1] if len(sys.argv) > 1 else None
    if sql:
        with open(f"src/aviation/sql/{sql}") as f:
            sql = f.read()
        print(duckdb.sql(sql).fetchall())
        exit(0)

    os.makedirs("results/", exist_ok=True)

    for table, sql in TABLES.items():
        with open(f"src/aviation/sql/{sql}") as f:
            sql = f.read()
        print(f"Processing {table}")
        sql = f"""
COPY (
{sql}
) TO 'results/{table}.csv' (HEADER, DELIMITER ',');
"""
        duckdb.sql(sql)


if __name__ == "__main__":
    main()

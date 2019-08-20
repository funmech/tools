"""GCP BigQuery operations"""

from pathlib import Path

import json
import sys

import requests
from google.cloud import bigquery


# export GOOGLE_APPLICATION_CREDENTIALS=~/Downloads/gcp_keys/key.json
# project is bound to the credential
client = bigquery.Client()


def list_tables(dataset_id):
    """List tables of a dataset"""
    # we need to result this list, so get it real
    tables = list(client.list_tables(dataset_id))
    print("Tables contained in '{}':".format(dataset_id))
    for table in tables:
        print("{}.{}.{}".format(table.project, table.dataset_id, table.table_id))
    return tables


def print_table_schema(table_id, save=False):
    """table_id: project_id.dataset_id.table_id"""
    table = client.get_table(table_id)
    print(
        "Got table '{}.{}.{}'.".format(table.project, table.dataset_id, table.table_id)
    )
    # View table properties
    print("Table description: {}".format(table.description))
    print("Table has {} rows".format(table.num_rows))
    print("Table schema: {}".format(table.schema))
    if table.schema:
        print(json.dumps(table.to_api_repr()["schema"], indent=2))
        if save:
            with open("{}_schema.json".format(table.table_id), "wt") as jf:
                json.dump(table.to_api_repr()["schema"], jf, indent=2)


def print_schemas(dataset_id, save=True):
    """Print schemas of tables, save them when required"""
    tables = list_tables(dataset_id)
    for table in tables:
        print_table_schema(table.full_table_id.replace(":", "."), save)


def load_from_json(dataset_id, fn, table_name):
    dataset_ref = client.dataset(dataset_id)
    job_config = bigquery.LoadJobConfig(
        autodetect=True, source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON
    )
    new_table = dataset_ref.table(table_name)
    with open(fn, "rb") as sf:
        load_job = client.load_table_from_file(
            sf, new_table, job_config=job_config
        )  # API request
    print("Starting job {}".format(load_job.job_id))
    load_job.result()  # Waits for table load to complete.
    print("Job finished.")
    destination_table = client.get_table(new_table)
    print("Loaded {} rows.".format(destination_table.num_rows))


def create_tables(dataset_id, working_dir):
    """Create tables for prepating upload of files from working_dir

    file name is the table name to be created
    """
    # Create a list of table's short names
    table_names = [table.table_id for table in list_tables(dataset_id)]

    # create tables first based on JSON files in hand
    for jf in Path(working_dir).expanduser().glob("*.json"):
        if jf.stem not in table_names:
            table_id = "{}.{}.{}".format(client.project, dataset_id, jf.stem)
            print(f"To create {table_id}")
            new_table = client.create_table(table_id)
    list_tables(dataset_id)


def upload(dataset_id, working_dir):
    """Upload ND JSON files from working_dir

    file name is the table name to be created
    """
    # all JSON files have to be ND JSON
    for jf in Path(working_dir).expanduser().glob("*.json"):
        print(jf.name, jf.stem, jf.suffix)
        if jf.stat().st_size > 0:
            try:
                load_from_json(dataset_id, jf.as_posix(), jf.stem)
            except requests.exceptions.ReadTimeout:
                # this has not seen in action yet,
                print("Raw retry once after default 6 times?")
                load_from_json(dataset_id, jf.as_posix(), jf.stem)
            except requests.exceptions.ReadTimeout:
                print("Give up")
            except Exception as err:
                print(err)


# some examples how these methods can be used
if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(
            "Missing position argument dataset id. Run as: %s my-dateset" % sys.argv[0]
        )

    # generally, we just need dataset_id, for upload, working with local file, we need working_dir
    dataset_id = sys.argv[1]
    if len(sys.argv) == 3:
        working_dir = sys.argv[2]
        # if you provided, it has to exists
        assert Path(working_dir).exists()

    # create_tables(dataset_id, working_dir)
    upload(dataset_id, working_dir)

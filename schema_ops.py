import json
import sys

from pathlib import Path, PurePath


def read_schemas(working_dir):
    """Create tables for prepating upload of files from working_dir
    """
    print("Looking into %s" % working_dir)
    return [
        {"file_name": jf.stem, "fields": json.loads(jf.read_text())["fields"]}
        for jf in Path(working_dir).expanduser().glob("*_schema.json")
        if jf.stat().st_size > 0
    ]


def _new_record_type(name, fields):
    """Create place holder for composited field"""
    return {"name": name, "type": "RECORD", "mode": "NULLABLE", "fields": fields}


def concat_schemas(schemas):
    """Concat schemas into a new schema: each one of them is a column as a record type"""
    return [_new_record_type(s["file_name"], s["fields"]) for s in schemas]


def save(file_name, schema, name_modifier=None):
    """Save a BigQuery table's schema to a file

    Top field names can be modified if name_modifier has been assigned
    """
    if name_modifier:
        for field in schema:
            print(field["name"])
            field["name"] = name_modifier(field["name"])

    print(json.dumps(schema, indent=2))
    with open(file_name, "wt") as jf:
        json.dump(schema, jf)


if __name__ == "__main__":
    working_dir = "."
    if len(sys.argv) == 2:
        working_dir = sys.argv[1]

    # print(json.dumps(concat_schemas(read_schemas(working_dir)), indent=2))
    save(
        PurePath(working_dir, "combined_schema.json"),
        concat_schemas(read_schemas(working_dir)),
        lambda n: n.split("_")[0],
    )

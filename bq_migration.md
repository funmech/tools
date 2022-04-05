# migrate a dataset to another one

## Setup shell environment variables
```shell
export BUCKET_LOCATION=australia-southeast2
export SOURCE_PROJECT=YOUR_SOURCE
export TARGET_PROJECT=YOUR_TARGET
export DATASET=warehouse_dataset
```

## Common steps
1. Create a storage in a suitable location
2. Prepare a list of tables in a dataset or datasets
3. Extract data to storage
3. Get the schemas of tables
4. Create new dataset(s) and tables
5. Load data to new dataset(s)

### The consideration of storage location
1. Colocate your Cloud Storage buckets for loading data.

   If your BigQuery dataset is in a multi-regional location, the Cloud Storage bucket containing the data you're loading must be in a regional or multi-regional bucket in the same location. For example, if your BigQuery dataset is in the EU, the Cloud Storage bucket must be in a regional or multi-regional bucket in the EU.

   If your dataset is in a regional location, your Cloud Storage bucket must be a regional bucket in the same location. For example, if your dataset is in the Tokyo region, your Cloud Storage bucket must be a regional bucket in Tokyo.

   Exception: If your dataset is in the US multi-regional location, you can load data from a Cloud Storage bucket in any regional or multi-regional location.

2. Colocate your Cloud Storage buckets for exporting data.
   When you export data, the regional or multi-regional Cloud Storage bucket must be in the same location as the BigQuery dataset. For example, if your BigQuery dataset is in the EU multi-regional location, the Cloud Storage bucket containing the data you're exporting must be in a regional or multi-regional location in the EU.

   If your dataset is in a regional location, your Cloud Storage bucket must be a regional bucket in the same location. For example, if your dataset is in the Tokyo region, your Cloud Storage bucket must be a regional bucket in Tokyo.

   Exception: If your dataset is in the US multi-regional location, you can export data into a Cloud Storage bucket in any regional or multi-regional location.

```bash
# Find the location:
bq show --format=prettyjson $SOURCE_PROJECT:$DATASET

# check size
for t in `cat  ${DATASET}.tables.txt`; do
    bq show $SOURCE_PROJECT:$DATASET.${t} | head -5
    echo
done

# Because the dataset is in US multi-regional location, we are free to export to anywhere
gsutil mb -c standard -l $BUCKET_LOCATION -p $TARGET_PROJECT gs://${BUCKET_LOCATION}-bq-exporting

# verify
gsutil ls -p $TARGET_PROJECT gs://${BUCKET_LOCATION}-bq-exporting

# Get a list of tables in a dataset
bq ls -a --project_id $SOURCE_PROJECT $DATASET > ${DATASET}.tables.txt

# do some vim tricks to get a list can be used in a bash script
vim ${DATASET}.tables.txt

# exporting to storage, with wildcast file name for bigger table with more than 1 GB data
for t in `cat  ${DATASET}.tables.txt`; do
  bq extract --destination_format NEWLINE_DELIMITED_JSON --compression GZIP ${SOURCE_PROJECT}:${DATASET}.$t gs://${BUCKET_LOCATION}-bq-exporting/${DATASET}/${t}-*.json.gzip &
done

# check results
gsutil ls -l -p $TARGET_PROJECT gs://${BUCKET_LOCATION}-bq-exporting/$DATASET

# get schema
for t in `cat ${DATASET}.tables.txt`; do
  bq show --project_id $SOURCE_PROJECT --schema --format=prettyjson $DATASET.$t > ${DATASET}_schemas/${t}_schema.json &
done

# make dataset
bq mk --project_id $TARGET_PROJECT --location $BUCKET_LOCATION $DATASET

# load data, not validate for bigger ones, see the next statement
for t in `cat ${DATASET}.tables.txt`; do
 bq --location=$BUCKET_LOCATION --project_id $TARGET_PROJECT load --source_format=NEWLINE_DELIMITED_JSON ${DATASET}.$t \
 gs://${BUCKET_LOCATION}-bq-exporting/${DATASET}/$t.json.gzip ${DATASET}_schemas/${t}_schema.json &
done

# the bigger ones: when size of a table is bigger than 1GB, they have `-*.json` extension
for t in general_ledger_account_balance journal journal_line; do
 bq --location=$BUCKET_LOCATION --project_id $TARGET_PROJECT load --source_format=NEWLINE_DELIMITED_JSON ${DATASET}.$t \
 gs://${BUCKET_LOCATION}-bq-exporting/${DATASET}/$t-*.json.gzip ${DATASET}_schemas/${t}_schema.json &
done


# check tables in target project
bq ls -a --project_id $TARGET_PROJECT $DATASET

# check loaded size
for t in `cat  ${DATASET}.tables.txt`; do
    bq show $TARGET_PROJECT:$DATASET.${t} | head -5
    echo
done
```
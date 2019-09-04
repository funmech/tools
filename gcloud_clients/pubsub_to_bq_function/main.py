import base64
import json
import os

from gcloud_clients.bigquery_c import BQClient


def load(data):
    if not isinstance(data, list):
        print("BigQuery table only accept list of JSON")

    client = BQClient(os.environ["dataset"])
    rows = json.loads(data)
    print("To load %d rows" % len(rows))
    errors = client.insert(os.environ["table"], rows)
    if errors:
        print("there was some errors")
        print(errors)

    count = client.count(os.environ["table"])
    print("Total number of rows in BQ (includes buffer): %s" % count)


def pubsub_to_bq(event, context):
    """Background Cloud Function to be triggered by Pub/Sub.
    Args:
         event (dict):  The dictionary with data specific to this type of
         event. The `data` field contains the PubsubMessage message. The
         `attributes` field will contain custom attributes if there are any.
         context (google.cloud.functions.Context): The Cloud Functions event
         metadata. The `event_id` field contains the Pub/Sub message ID. The
         `timestamp` field contains the publish time.
    """
    print("""This Function was triggered by messageId {} published at {}
    """.format(context.event_id, context.timestamp))

    if 'data' in event:
        print("Load to bigquery table %s.%s" % (os.environ["dataset"], os.environ["table"]))
        load(base64.b64decode(event['data']))

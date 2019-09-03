import base64
import json
import os

from bigquery_c import BQClient


def load(data):
    client = BQClient(os.environ["dataset"])
    rows = json.loads(data)
    print("To load %d rows" % len(rows))
    print(client.insert(os.environ["table"], rows))
    client.describe_table(os.environ["table"])
    rows = client.count(os.environ["table"])
    client.print_rows(rows)


def hello_pubsub(event, context):
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
        name = base64.b64decode(event['data']).decode('utf-8')
    else:
        name = 'World'
    print('Hello {}!'.format(name))
    print("Load to bigquery table %s.%s" % (os.environ["dataset"], os.environ["table"]))
    load(base64.b64decode(event['data']))

"""Download predictions from datastore"""

import json
import sys

from datastore_c import DSClient


def _wrapper(entity):
    """Create prediction rows for BQ table from DS entity"""
    base = {"organisation_uid": entity.key.id_or_name}
    if "predicted_at" in entity:
        base["predicted_at"] = entity["predicted_at"].isoformat()

    rows = []
    for prediction in json.loads(entity['predictions']):
        row = base.copy()
        row[entity.kind] = prediction
        rows.append(row)
    return rows


def dowload(org_id):
    """Download predictions"""
    store = DSClient()

    PREDICTIONS = (
        "InvoiceReceivablePredictions",
        "InvoiceReceivableRecurringPredictions",
        "InvoicePayablePredictions",
        "InvoicePayableRecurringPredictions",
        "TransactionPredictions",
        "TransferPredictions",
    )

    # get filter keys
    keys = [store.key(kind, org_id) for kind in PREDICTIONS]
    return {entity.kind: _wrapper(entity) for entity in store.get_multi(keys)}


def save_predictions(values, nd=False, split=False):
    """Save all kinds of predictions to a json file

    ARGS:
        values (dict): keys are precition kind, values are predictions
        nd (bool): if it should be in NEWLINEDELIMITED format JSON
        split (boo): should generate one for all or each for a kind
    """
    assert isinstance(values, dict)
    if nd:
        saver = _save_nd_json
        fn_template = "{}_nd.json"
        print("Saving to ND JSON format")
    else:
        saver = _save_json
        fn_template = "{}.json"
        print("Saving to normal JSON format")

    if split:
        _save_individually(values, saver, fn_template)
    else:
        _save_all_in_one(values, saver, fn_template.format("all_in_one"))


def _save_all_in_one(values, saver, fn):
    # flat out kinds, ignore them
    new_values = []
    for v in values.values():
        new_values += v
    saver(new_values, fn)


def _save_individually(values, saver, fn_template):
    # save predictions into individual files using kind
    for k, v in values.items():
        saver(v, fn_template.format(k))


def _save_json(predictions, fn):
    """Save list of dict as json for viewing, for example"""
    with open(fn, "wt") as jf:
        json.dump(predictions, jf)


def _save_nd_json(predictions, fn):
    """Save list of dict to new line delimited (ND) json for uploading to GCP BQ"""
    # for existing json, uses jq: cat test.json | jq -c '.[]' > testNDJSON.json
    assert isinstance(predictions, list)
    with open(fn, "wt") as jf:
        for prediction in predictions:
            jf.write(json.dumps(prediction) + "\n")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Missing position argument org id. Run as: %s 0141j5tlqqrjijwu4mnayh" % sys.argv[0])

    print("To download predictions of the org with this ID: %s" % sys.argv[1])
    # default result is all_in_one_nd.json.
    # add extra positional arg, it will create normal json file all_in_one.json
    # manually add True to save_predictions to save files individually in different formats.

    if len(sys.argv) > 2:
        # save to ND format for BQ
        save_predictions(dowload(sys.argv[1]), False)
    else:
        save_predictions(dowload(sys.argv[1]), True)

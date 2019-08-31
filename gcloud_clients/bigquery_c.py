from google.cloud.bigquery import Client

from project import Info


class BQClient(Info, Client):
    """A client for querying a BigQuery dataset"""

    def __init__(self, dataset):
        super().__init__()
        self.dataset = dataset

    def _full_table_name(self, table):
        return "`%s.%s.%s`" % (self.project_id, self.dataset, table)

    def select(self, table, fields, conditions=None):
        QUERY = "SELECT %s FROM %s" % (",".join(fields), self._full_table_name(table))
        if conditions:
            QUERY += " %s" % ",".join(conditions)

        query_job = self.query(QUERY)  # API request
        return query_job.result()  # return an iterator

    @staticmethod
    def print_row(row):
        """Print a row with field names and values"""
        for k, v in row.items():
            print(f"{k} = {v}")

    @staticmethod
    def print_rows(rows):
        """Print rows with numbers and field names and values"""
        count = 0
        for row in rows:
            count += 1
            print(f"{count}:")
            for k, v in row.items():
                print(f"\t{k} = {v}")


if __name__ == "__main__":
    client = BQClient("save_predictions_test_one")
    rows = client.select("all_in_one", ["COUNT(*) AS total"])
    client.print_rows(rows)

    rows = client.select("all_in_one", ("organisation_uid", "predicted_at"))
    client.print_rows(rows)
## Simple GCP clients package for quickly doing simple things


### To quickly run
1. `export GOOGLE_APPLICATION_CREDENTIALS=path/key.json`
1. run a demo script (has to be outside the package itself):
   `python -m gcloud_clients.bigquery_c`

### Extra
The clients get basic project information from `GOOGLE_APPLICATION_CREDENTIALS`, so
there is no need to set this for running. It is recommended to use service accounts
for scripting, not your own credential. So if there are warnings, **do the right thing**.

There is not much of error handlings. Some times you have Python errors, some times you
have grpc errors.

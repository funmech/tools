# Examples of setting up https://github.com/jcustenborder/kafka-connect-spooldir

This connector can be used for streaming different files into Kafka. It is also very handy for trying out Simple Message Transform or other features of Kafka connect.

## Steps
1. Define services of a Kafka for docker compose in a config file like [this](example-docker-compose.yml).
1. Build a cutosmised image with `kafka-connect-spooldir` installed. The jar file can be downloaded from [Confluent Hub](https://www.confluent.io/hub/jcustenborder/kafka-connect-spooldir#:~:text=Version%202.0.65-,Download,-Plugin%20type%3A).
   Details and examples of building customeised images with extra plug-ins, you can reference this [page](https://docs.confluent.io/5.2.4/connect/managing/extending.html). An example docker file is given [here](fs-connect.yaml) and used in the following steps.
1. Update the docker compose file like [this](docker-compose.yml) to use the connect image with the connector just built.
1. Run the services: `docker-compose up -d`. *Note*: the services defined in compose files are not selected nor optimised so it needs no less than 6G memory to start.
   I use `colima` to run containers, so I have to give it enough resources: `colima start --cpu 2 --memory 8`.
1. Some `kafka-connect-spooldir` connectors need at lease a file presents when it is created, so first ssh into the `connect` container: `docker exec -it connect bash`.
   and prepare some files in the location. In the examples shown here, the location is `/tmp/data`.
1. Create some source connectors. You can find two examples of config file in [config](config/). To create one, run:
   `curl -X POST -H "Content-Type: application/json" --data @config/spdir_json.json http://localhost:8083/connectors`

## Notes
1. If you want to try to let the connector generates schema when it starts, make sure a file is ready when it starts. Otherwise you have to
   restart the connector to make it work. Call `docker logs connect` to see the error messages.
1. `value.schema` is a string. So you have to escape the double quotation marks of the JSON object.
1. Example data files and schemas can be found from the (repository](https://github.com/jcustenborder/kafka-connect-spooldir/tree/master/src/test/resources/com/github/jcustenborder/kafka/connect/spooldir/json).
1. [Doc site](https://jcustenborder.github.io/kafka-connect-documentation/index.html) of `kafka-connect-spoodir`.
1. SMT:
   1. https://docs.confluent.io/cloud/current/connectors/single-message-transforms.html
   1. https://www.confluent.io/blog/kafka-connect-single-message-transformation-tutorial-with-examples/
   1. https://github.com/confluentinc/demo-scene/tree/master/kafka-connect-single-message-transforms

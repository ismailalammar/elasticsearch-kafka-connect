# Kafka Connect with MySQL and Elasticsearch #
![alt text](/.github/static/project.png "flow")
This project demonstrates how to stream data from a MySQL database to Elasticsearch using Kafka Connect. The goal is to ensure that any changes in the MySQL database are automatically reflected in Elasticsearch in real-time.

## Prerequisites
Before you begin, ensure you have Docker and Docker Compose installed on your system.

## Project Structure
```bash 
├── docker-compose.yaml
├── data/
│ ├── mysql
├──   ├── 00_setup_db.sql
├──   ├── 01_create_schema.sql
├──   ├── 02_populate_data.sql
└── README.md
```

## Getting Started
1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/ismailalammar/elasticsearch-kafka-connect.git
   cd elasticsearch-kafka-connect
    ```
2. Start the Docker Compose
   ```bash
   docker-compose up -d
    ```
    > **_NOTE:_**  Kafka Connect may take a few minutes to start up and become ready. Ensure that Kafka Connect is healthy before proceeding. You can check the status of the Kafka Connect service with the following command: docker-compose ps

3. Configure Kafka Connect
    1. Source Connector: this connector will listen to any changes from database (create-update-delete) and stream those changes to Kafka broker under specific topic.
        ```bash
        curl --location --request PUT 'http://localhost:8083/connectors/source-debezium-orders-00/config' \
        --header 'Content-Type: application/json' \
        --data '{
            "connector.class": "io.debezium.connector.mysql.MySqlConnector",
            "database.hostname": "mysql",
            "database.port": "3306",
            "database.user": "username",
            "database.password": "password",
            "database.server.id": "421",
            "table.whitelist": "demo.orders",
            "delete.handling.mode" : "rewrite",
            "topic.prefix" : "kc.ts",
            "schema.history.internal.kafka.topic": "schema-changes.demo",
            "schema.history.internal.kafka.bootstrap.servers": "broker:29092"
        }'
        ```
    2. Sink Connector: this connector will be consuming changes from the specified Kafka topic and index the changes into Elasticsearch.
        ```bash
        curl --location --request PUT 'http://localhost:8083/connectors/sink-elastic-orders-00/config' \
        --header 'Content-Type: application/json' \
        --data '{
            "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
            "topics": "kc.ts.demo.orders",
            "connection.url": "http://elasticsearch:9200",
            "type.name": "type.name=kafkaconnect",
            "pk.fields" : "id",
            "insert.mode" : "upsert",
            "delete.enabled" : true,
            "behavior.on.null.values": "DELETE"
        }'
        ```
  
4. Connect to MySQL and Insert Data.
    1. connect to MySQL using this command
        ```sh
        docker exec -it mysql bash -c 'mysql -u root -p$MYSQL_ROOT_PASSWORD demo'
        ```
    2. Insert data
        ```sql
        insert into orders (customer_id, order_total_usd, make, model, delivery_city, delivery_company, delivery_address) values ( 101010, 197745.59, 'TST', 'TST Car', 'Berlin', 'TST Group', 'dummy Street');
        ```
5. Check Elasticsearch for the new data.
    ```sh
    curl -X GET "localhost:9200/kc.ts.demo.orders/_search" -H 'Content-Type: application/json' -d'
    {
        "query": {
            "term": {
            "after.customer_id": {
                "value": 101010
            }
          }
        }
    }'
    ```

## Conclusion
By following this guide, you should have a working setup that streams changes from a MySQL database to Elasticsearch using Kafka Connect. This setup ensures real-time synchronization between your database and search engine, allowing for efficient and up-to-date data retrieval.

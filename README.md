# webdwh_client

A turnkey Docker Compose solution for streaming real-time market indicators (Forex, etc.) directly into your local or VPS time-series database.

---

## 💡 Concept

The project implements a classic Publisher/Subscriber architecture designed to deliver high-frequency market data to end-users with minimal latency.

1. **Data Provider (Server):** Real-time web pumps (parsers) continuously aggregate market indicators and publish them to a central **NATS** message broker.
2. **Data Consumer (Client):** Users deploy the `webdwh_client` stack locally or on a VPS.

### What is inside the `webdwh_client` stack?
* **Time-Series Database:** A pre-configured **TimescaleDB** instance (PostgreSQL extension) optimized for high-performance storage and rapid analysis of financial ticks and quotes.
* **Stream Connector:** An automated service that connects to the central NATS broker, listens to data streams, and instantly ingests incoming market data into the database using optimized procedures.

---

## 🛠️ Setup & Installation

Follow these steps to initialize the environment and configure your credentials.

### Step 1: Clone and Initialize

Clone the repository, create local configuration files from examples, and initialize the database schema:

```bash
# Clone the repository and navigate to the project directory
git clone https://github.com/pv14mn/webdwh_client.git
cd webdwh_client

# Create local environment configuration files from examples
cp ./node/.env.nats.auth.txt.example ./node/.env.nats.auth.txt
cp ./node/.env.load.params.txt.example ./node/.env.load.params.txt
cp ./timescaledb/.env.db.auth.txt.example ./timescaledb/.env.db.auth.txt
```

> ⚠️ **Important:** Before proceeding, you need to configure the environment files:
> * **`node/.env.nats.auth.txt`** — **Required**. Fill in your NATS connection credentials.
> * **`timescaledb/.env.db.auth.txt`** and **`node/.env.load.params.txt`** — Contain default settings and passwords. These are fine for containerized environments, but you can modify them if necessary.

```bash
# Pull required images and initialize the database
docker compose pull --policy missing
docker compose up -d timescaledb
# wait 10 sec
docker compose run --rm db-init
```

> ⚠️ **Please note:** A persistent Docker volume named `webdwh_client_postgres_data` will be automatically created to preserve your financial data across container restarts.

---

## 🚀 Usage

### Start the Stack
Run the entire infrastructure in the background (detached mode):
```bash
docker compose up -d
```

### Stop the Stack
Shut down all running containers securely:
```bash
docker compose down
```

### Connect to the Database
You can connect using any compatible SQL client (such as DBeaver) on port `5400`.

Connection details:
* **Database Name:** `postgres` (TimescaleDB)
* **Default user:** `webdwh` / `webdwh`
* **Admin user:** `postgres` / `postgres` (for administration)
* **Viewer user:** `viewer` / `viewer` (read-only access)

### Data Collection & Buffering
Data is collected from the following sources:
* https://www.mql5.com/ru/quotes/currencies/forex-matrix
* https://www.profinance.ru/quotes

Incoming ticks for each ticker are accumulated in a buffer. By default, every `1000 ms` the latest value from the buffer is flushed to the database. 

You can change this interval in the `./node/.env.load.params.txt` file. To apply changes, restart the stack:
```bash
docker compose up -d
```

### Querying Data
To view the latest snapshot of the Forex market, run the following query:

```sql
select t.description, t.scode, q.evts, q.ask, q.bid, q.tick_cnt
  from mql.quotes_last q
  join mql.tickers t
    on t.icode = q.icode
where 1=1
order by q.evts desc
```

### TimescaleDB Optimization & Data Retention
Fact tables (hypertables) are partitioned by the `evts` timestamp with a 1-hour interval. By default, partitions older than 3 hours are compressed and converted into a columnar format. 

You can set up a retention policy to automatically drop historical data older than a specific interval:
```sql
select add_retention_policy(relation=>'mql.quotes', drop_after=>interval'3 month', schedule_interval=>interval'1 day');
-- select remove_retention_policy(relation=>'mql.quotes');
```

To list all available hypertables, use:
```sql
SELECT * FROM timescaledb_information.hypertables;
```

To check the exact size of a specific hypertable in megabytes, run:
```sql
select hypertable_size('mql.quotes')::numeric/1024/1024 AS mb;
```

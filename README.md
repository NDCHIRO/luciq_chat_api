# Luciq Chat API

A scalable messaging backend built with **Ruby on Rails + MySQL + Redis + Sidekiq**, supporting:

✅ Multi-tenant applications  
✅ Chats inside each application  
✅ Messages inside each chat  
✅ Auto-increment chat & message numbers  
✅ Redis counters & Sidekiq jobs  
✅ Eventual consistency sync (every 1 min)  
✅ Search messages (SQL LIKE; Elasticsearch optional)

This simulates a real-world chat backend like WhatsApp/Messenger.

## 🚀 Stack

| Component | Purpose |
|----------|--------|
Ruby on Rails 8 | Core API  
MySQL | Primary DB  
Redis | Counters & message sequencing  
Sidekiq | Background workers  
Sidekiq-Cron | Scheduled Redis → DB sync  
Docker Compose | Local infrastructure  


## Architecture (High-Level)

### Models
- **Application**
  - Has many Chats
  - Identified externally by a unique `token`
  - Stores `chats_count` (counter cache)
  - Stores `messages_count`

- **Chat**
  - Belongs to Application
  - Has many Messages
  - Has sequential `number` per application (1,2,3…)
  - Stores `messages_count` (DB value is eventually consistent with Redis)

- **Message**
  - Belongs to Chat
  - Has sequential `number` per chat
  - Inserted immediately into DB
  - Counter updates are deferred to Redis + Sidekiq sync


- Message creation:
  - Message row is inserted immediately into **MySQL**
  - `number` is generated using **Redis** to avoid race conditions
  - Messages increments stored **in Redis first**
  - DB counter (`messages_count`) updated later by Sidekiq Cron (~1 min)

- Application total messages:
  - Sum of all chat message counts
  - Redis counts take priority during sync
  - DB stores the persistent final value

| Operation | Where it happens |
|----------|------------------|
Insert message | ✅ Direct DB insert  
Increment counters | ✅ Redis (fast)  
Sync counters to DB | ✅ Sidekiq Cron (1-minute delay)  

This ensures **high write throughput** and **eventual consistency**.

## 🛠 Background Sync

Redis counters synced to DB ~every 1 minute (Sidekiq-Cron)

Ensures DB stays consistent but not updated instantly

---
## Getting started

### Run with Docker (recommended)
```bash
git clone <repo>
cd project
docker compose up --build
# App: http://localhost:3000
# MySQL: localhost:3306 (mapped to container :3307)
# Redis: localhost:6379
```

### Run locally (without Docker)
```bash
bundle install
# Ensure MySQL is running on localhost:3306 or set DB_HOST/DB_PORT
RAILS_ENV=development DB_HOST=127.0.0.1 DB_PORT=3306 bundle exec rails db:create db:migrate
bundle exec rails s -b 0.0.0.0 -p 3000
```

### Background jobs (Sidekiq)
```bash
bundle exec sidekiq -C config/sidekiq.yml
```


## Database commands
```bash
# DB
bundle exec rails db:create db:migrate
bundle exec rails db:reset   # drop + create + migrate
```


## API quickstart
All endpoints are JSON.

## Applications
|Method	|Endpoint|	                            Description
|----------|--------|--------|
POST	|/applications|	                        Create new app
GET	    |/applications/:token|	                Get app info
PATCH	|/applications/:token|	                Update / rename app
GET	    |/applications/:token/message_count|	    Total messages in app


## Chats
|Method	|Endpoint	|                                            Description
|----------|--------|--------|
POST	|/applications/:token/chats	       |                     Create chat
GET	 |   /applications/:token/chats	       |                     List chats
GET	 |   /applications/:token/chats/:chat_number|	                Chat details
GET	   | /applications/:token/chats/:chat_number/message_count|	Chat messages count



## Messages
|Method|	Endpoint	   |                                                     Description
|----------|--------|--------|
POST	|/applications/:token/chats/:chat_number/messages	|                Create message
GET	 |   /applications/:token/chats/:chat_number/messages	  |              List messages
GET	|    /applications/:token/chats/:chat_number/messages/:message_number|	Show message
GET	 |   /applications/:token/chats/:chat_number/messages/search?q=text	 |   Search messages



## Implementation notes
- Redis keys used
  - `chat:<chat_id>:message_number` for next message number (INCR)
  - `chat:<chat_id>:messages_count` for per‑chat message count
- Counter caches
  -  `chats.messages_count`
- Periodic syncing 
  - Workers exist for syncing counts from Redis to MySQL; scheduling requires adding `sidekiq-cron`.

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


## Architecture (high-level)
- Models
  - Application: has many Chats, token is the public identifier; maintains `chats_count` via counter cache.
  - Chat: belongs to Application, has many Messages; sequential `number` per application; maintains `messages_count` via counter cache.
  - Message: belongs to Chat; sequential `number` per chat.
- Routes (nested, tokenized)
  - `/applications/:token`
    - `/chats` (`:chat_number`)
      - `/messages` (`:message_number`), plus `/messages/search?q=...`
- Message numbering and counts
  - Message create uses Redis to generate the next `number` and to bump a per‑chat `messages_count` key; DB also enforces uniqueness and stores counter caches.
  - Application total messages is computed as the sum of each chat’s `messages_count` (DB), with optional Redis fallback.

## Getting started

### Prerequisites
- Ruby 3.3
- MySQL 8
- Redis 7
- Bundler

### Run with Docker (recommended)
```bash
git clone <repo>
cd project
docker compose up --build
# App: http://localhost:3000
# MySQL: localhost:3307 (mapped to container :3306)
# Redis: localhost:6379
```

### Run locally (without Docker)
```bash
bundle install
# Ensure MySQL is running on localhost:3307 or set DB_HOST/DB_PORT
RAILS_ENV=development DB_HOST=127.0.0.1 DB_PORT=3307 bundle exec rails db:create db:migrate
bundle exec rails s -b 0.0.0.0 -p 3000
```

### Background jobs (Sidekiq)
```bash
bundle exec sidekiq -C config/sidekiq.yml
```
Note: `config/sidekiq_schedule.yml` exists but cron loading is not wired by default. To enable periodic jobs, add `sidekiq-cron` and load that YAML in `config/initializers/sidekiq.rb`.

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
Method	Endpoint	                                            Description
POST	/applications/:token/chats	                            Create chat
GET	    /applications/:token/chats	                            List chats
GET	    /applications/:token/chats/:chat_number	                Chat details
GET	    /applications/:token/chats/:chat_number/message_count	Chat messages count



## Messages
Method	Endpoint	                                                        Description
POST	/applications/:token/chats/:chat_number/messages	                Create message
GET	    /applications/:token/chats/:chat_number/messages	                List messages
GET	    /applications/:token/chats/:chat_number/messages/:message_number	Show message
GET	    /applications/:token/chats/:chat_number/messages/search?q=text	    Search messages

- Create application
```bash
curl -X POST http://localhost:3000/applications \
  -H "Content-Type: application/json" \
  -d '{"application": {"name": "Demo"}}'
```
- Show application
```bash
curl http://localhost:3000/applications/<APP_TOKEN>
```
- Update application name
```bash
curl -X PATCH http://localhost:3000/applications/<APP_TOKEN> \
  -H "Content-Type: application/json" \
  -d '{"application": {"name": "New Name"}}'
```
- Get application total messages
```bash
curl http://localhost:3000/applications/<APP_TOKEN>/message_count
```
- List chats, create chat, show chat
```bash
curl http://localhost:3000/applications/<APP_TOKEN>/chats
curl -X POST http://localhost:3000/applications/<APP_TOKEN>/chats
curl http://localhost:3000/applications/<APP_TOKEN>/chats/<CHAT_NUMBER>
```
- List/create/show messages; search messages in a chat
```bash
curl http://localhost:3000/applications/<APP_TOKEN>/chats/<CHAT_NUMBER>/messages
curl -X POST http://localhost:3000/applications/<APP_TOKEN>/chats/<CHAT_NUMBER>/messages \
  -H "Content-Type: application/json" \
  -d '{"message": {"body": "hello"}}'
curl http://localhost:3000/applications/<APP_TOKEN>/chats/<CHAT_NUMBER>/messages/<MESSAGE_NUMBER>
curl "http://localhost:3000/applications/<APP_TOKEN>/chats/<CHAT_NUMBER>/messages/search?q=hello"
```

## Implementation notes
- Redis keys used
  - `chat:<chat_id>:message_number` for next message number (INCR)
  - `chat:<chat_id>:messages_count` for per‑chat message count
- Counter caches
  - `applications.chats_count`, `chats.messages_count`
- Periodic syncing (optional)
  - Workers exist for syncing counts from Redis to MySQL; scheduling requires adding `sidekiq-cron`.

## Troubleshooting
- 404 on nested routes often indicates param key mismatch. Controllers expect `application_token` (applications) and `chat_number` (chats) from the path.
- If running locally without Docker, ensure MySQL is on port 3307 or update `config/database.yml` via `DB_HOST`/`DB_PORT`.

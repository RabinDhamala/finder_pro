# 🕵️‍♂️ FinderPro

A simple Ruby-based **command-line** and **REST API** app to search client data and detect duplicate emails from a structured JSON dataset.

---

## 📁 Project Structure

```
finder_pro/
├── bin/
│   └── cli.rb                      # CLI entry point
├── api/
│   └── app.rb                      # Sinatra API entry point
├── lib/
│   └── finder_pro/
│       ├── models/
│       │   └── client.rb
│       ├── services/
│       │   ├── client_store.rb
│       │   ├── client_loader.rb
│       │   ├── duplicate_finder.rb
│       │   ├── pagination.rb
│       │   └── searcher.rb
│       └── finder_pro.rb           # Core namespace loader
├── data/
│   └── clients.json
├── spec/
│   ├── api/
│   │   └── app_spec.rb
│   ├── cli/
│   │   └── cli_spec.rb
│   ├── services/
│   │   ├── searcher_spec.rb
│   │   ├── duplicate_finder_spec.rb
│   │   └── client_loader_spec.rb
│   └── fixtures/
│       └── clients.yml
├── public/                         # Swagger UI
├── config.ru                      # Rack configuration
├── Gemfile
└── README.md
```

---

## 🔧 Setup

### 1. Install dependencies

Make sure Ruby (≥ 3.0) is installed, navigate to the root directory and then run:

```bash
bundle install
```

---

## 🖥️ Command-Line Usage

Run commands from the project root.

### 🔍 Search Clients by Field

```bash
ruby bin/cli.rb search <field> <query>
```

**Examples:**

```bash
ruby bin/cli.rb search full_name John
ruby bin/cli.rb search email example@
```

**With a custom dataset:**

```bash
ruby bin/cli.rb --file data/clients_backup.json search email jane@
```

---

### 📧 Find Duplicate Emails

```bash
ruby bin/cli.rb duplicates
```

**With a custom dataset:**

```bash
ruby bin/cli.rb --file data/clients_backup.json duplicates
```

---

## 🌐 REST API

### ▶️ Start the Server

```bash
ruby api/app.rb
```

The app will start on: [http://localhost:3000](http://localhost:3000)

### 📚 Swagger UI

Visit [http://localhost:3000/docs](http://localhost:3000/docs) to test endpoints:

- `GET /query` – Search clients
- `GET /duplicates` – View duplicate emails
- `POST /upload` – Upload and replace the dataset

---

### 🔁 Example API Usage

#### `GET /query`

Search clients by query:

```http
GET /query?q=john&field=email
```

Query params:
- `q`: The search keyword (required)
- `field`: Field to search on (default: `full_name`)
- `page`: Page number (optional)
- `per_page`: Items per page (optional)

#### `GET /duplicates`

Returns duplicate emails across clients.

#### `POST /upload`

Uploads a new JSON dataset (multipart upload):

```json
[
  { "id": 1, "full_name": "John Doe", "email": "john@example.com" }
]
```

Send this via form data with key: `file`.

---

## 🧪 Run Tests

```bash
bundle exec rspec                      # Run all specs
bundle exec rspec spec/services/...   # Run specific test file
```

---

## 🧠 Design Notes & Assumptions

- Uses modular service objects for clean structure.
- CLI and REST API share a unified backend via `ClientStore`.
- All data is kept in-memory (not persisted between sessions).
- JSON format is an array of objects with `id`, `full_name`, and `email`.
- Searches are case-insensitive and support partial matches.

---

## 🚧 Future Improvements

- [ ] Add versioning support for the API (`/v1/...`)
- [ ] Persist uploaded data to disk or use DB
- [ ] Add authentication layer for REST API
- [ ] Dockerize the app for easier deployment
- [ ] CLI enhancements: export results to CSV/JSON
- [ ] Improve Swagger docs (add request/response examples)

---

## 👨‍💻 Author

Built by [Your Name] — [GitHub](https://github.com/RabinDhamala)
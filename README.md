# TimeStay - Timezone & Country Time Service 🕐

A beginner-friendly Rails API-only project that provides timezone information and current time for countries around the world.

## 🎯 Features

- Get current time for multiple countries
- List all available timezones (UTC/GMT offsets)
- View countries within a specific timezone
- No database required
- Fully Dockerized

## 🛠️ Tech Stack

- Ruby 4.0
- Rails 8.1.1 (API mode)
- Docker & Docker Compose
- ActiveSupport::TimeZone

## 🚀 Getting Started

### Using Docker (Recommended)

```bash
# Build and start the application
docker compose up --build

# The API will be available at http://localhost:3000
```

### Without Docker

```bash
# Install dependencies
bundle install

# Start the server
bin/rails server
```

## 📡 API Endpoints

All endpoints are versioned under `/api/v1`.

### 1. Get Current Time for Countries

```
GET /api/v1/time/current?countries=Japan,China
```

**Example Response:**
```json
{
  "results": [
    {
      "country": "Japan",
      "timezone": "Asia/Tokyo",
      "current_time": "2026-01-03T13:00:00+09:00"
    },
    {
      "country": "China",
      "timezone": "Asia/Shanghai",
      "current_time": "2026-01-03T12:00:00+08:00"
    }
  ]
}
```

### 2. List All Timezones

```
GET /api/v1/zones
```

**Example Response:**
```json
{
  "count": 150,
  "zones": [
    {
      "name": "Pacific/Midway",
      "offset": "-11:00",
      "utc_offset": -39600
    },
    ...
  ]
}
```

### 3. Get Timezone Details

```
GET /api/v1/zones/Asia%2FTokyo
```

> Note: Use URL encoding for the zone name (replace `/` with `%2F`)

**Example Response:**
```json
{
  "name": "Asia/Tokyo",
  "offset": "+09:00",
  "current_time": "2026-01-03T13:00:00+09:00",
  "countries": ["Japan"]
}
```

## 📁 Project Structure

```
TimeStay/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── api/
│   │       └── v1/
│   │           ├── zones_controller.rb      # Timezone endpoints
│   │           └── time/
│   │               └── current_controller.rb # Current time endpoint
│   └── services/
│       └── timezone_service.rb              # Business logic
├── config/
│   ├── routes.rb                            # API routes
│   └── timezone_mappings.yml                # Country → Timezone data
├── Dockerfile
└── docker-compose.yml
```

## 🧠 Architecture

This project follows clean architecture principles:

| Layer | Responsibility |
|-------|---------------|
| **Controllers** | Handle HTTP requests and responses |
| **Services** | Contain business logic |
| **Config YAML** | Store static data (country mappings) |

## 🌍 Supported Countries

The API supports 80+ countries including:
- **Asia**: Japan, China, South Korea, India, Singapore, Thailand, etc.
- **Europe**: UK, France, Germany, Italy, Spain, etc.
- **Americas**: USA, Canada, Mexico, Brazil, Argentina, etc.
- **Middle East**: Saudi Arabia, UAE, Israel, Turkey, etc.
- **Africa**: Egypt, South Africa, Nigeria, Kenya, etc.
- **Oceania**: Australia, New Zealand, Fiji, etc.

See `config/timezone_mappings.yml` for the full list.

## 🧪 Testing the API

Using curl:

```bash
# Get current time for Japan and China
curl "http://localhost:3000/api/v1/time/current?countries=Japan,China"

# List all timezones
curl "http://localhost:3000/api/v1/zones"

# Get Tokyo timezone details
curl "http://localhost:3000/api/v1/zones/Asia%2FTokyo"
```

## 📝 Learning Notes

### Why No Database?

This project uses `ActiveSupport::TimeZone` which is built into Rails. Timezone data is maintained by the IANA and included in Ruby's tzinfo gem. Country mappings are stored in a simple YAML file.

### Why Service Objects?

Service objects keep controllers thin and focused on HTTP concerns. All business logic lives in `TimezoneService`, making the code:
- Easier to test
- More reusable
- Simpler to understand

### Why API Versioning?

Using `/api/v1` allows us to make breaking changes in the future (v2, v3) without breaking existing clients.

## 📄 License

This project is for learning purposes. Feel free to use and modify as needed.

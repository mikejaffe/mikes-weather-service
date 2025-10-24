# Weather App

A Rails 8 application that provides weather forecasts for any address using geocoding and the Open-Meteo API.

## Features

- Get current temperature and 7-day weather forecast for any address
- Address geocoding using Nominatim (OpenStreetMap)
- 30-minute caching by zip code for improved performance

## Prerequisites

- Ruby 3.4.7
- SQLite3
- **APIs**: 
  - [Open-Meteo](https://open-meteo.com/) - Free weather API (no key required)
  - [Nominatim](https://nominatim.org/) - Free geocoding service

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mikejaffe/mikes-weather-service
   cd weatherapp
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup the database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```
   ```

## Running the Application

### Development Server

Start the Rails server:
```bash
bin/dev
```

Visit `http://localhost:3000` in your browser.

### Production Docker

To test the production Docker build locally:

1. **Build the Docker image:**
   ```bash
   docker build -t weatherapp .
   ```

2. **Run the container:**
   ```bash
   docker run -d -p 3000:80 \
     -e RAILS_MASTER_KEY=$(cat config/master.key) \
     --name weatherapp \
     weatherapp
   ```

3. **View logs:**
   ```bash
   docker logs -f weatherapp
   ```

4. **Visit the app:**
   Open `http://localhost:3000` in your browser.

5. **Stop and remove the container:**
   ```bash
   docker stop weatherapp
   docker rm weatherapp
   ```

### Using the App

1. Enter any address in the search box (e.g., "New York, NY")
2. Click "Get Weather"

## Running Tests

Run the full test suite:
```bash
bundle exec rspec
```

## Configuration

### Caching

To clear the cache:
```bash
bin/rails cache:clear
```

### Cache Not Working

Verify that the database cache tables exist:
```bash
bin/rails db:migrate
```
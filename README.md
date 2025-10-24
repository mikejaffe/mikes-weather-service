# Weather App

A Rails 8 application that provides weather forecasts for any address using geocoding and the Open-Meteo API.

## Features

- Get current temperature and 7-day weather forecast for any address
- Address geocoding using Nominatim (OpenStreetMap)
- 30-minute caching by zip code for improved performance

## Prerequisites

- Ruby 3.4.7 (use rbenv, rvm, or asdf to manage Ruby versions)
- SQLite3
- Bundler gem (`gem install bundler`)
- **APIs**: 
  - [Open-Meteo](https://open-meteo.com/) - Free weather API (no key required)
  - [Nominatim](https://nominatim.org/) - Free geocoding service

## Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
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

**Note:** The production Docker image:
- Runs on port 80 internally (mapped to 3000 on host)
- Uses Thruster as the HTTP server
- Requires `RAILS_MASTER_KEY` for encrypted credentials
- Auto-migrates the database on startup

### Using the App

1. Enter any address in the search box (e.g., "1600 Amphitheatre Parkway, Mountain View, CA")
2. Click "Get Weather"
3. View current temperature, daily high/low, and 7-day forecast
4. Subsequent requests for the same zip code are cached for 30 minutes

## Running Tests

Run the full test suite:
```bash
bundle exec rspec
```

Run specific test files:
```bash
bundle exec rspec spec/services/weather_service_spec.rb
bundle exec rspec spec/requests/home_spec.rb
```

## Configuration

### Caching

The app uses Rails 8's Solid Cache (database-backed caching) by default. Cache entries expire after 30 minutes and are keyed by zip code.

To clear the cache:
```bash
bin/rails cache:clear
```

### Cache Not Working

Verify that the database cache tables exist:
```bash
bin/rails db:migrate
```
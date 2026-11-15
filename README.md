# Westland Weather (`weather`)

A lightweight Bash script that fetches and displays the current weather conditions for Westland, MI (zip code 48185) in ANSI blue text.

Powered by the [Open-Meteo](https://open-meteo.com/) free weather API (no API key required).

## Features

- **Current Conditions**: Weather status (e.g., Clear, Cloudy, Rain, Snow)
- **Temperature**: Current temperature and apparent ("feels like") temperature in °F
- **Daily Extremes**: Today's forecasted high and low temperatures in °F
- **Precipitation**: Current precipitation and rain accumulation in inches
- **Rain Probability**: Today's maximum chance of precipitation (%)
- **Atmospheric Stats**: Relative humidity (%) and wind speed (mph)
- **Terminal Friendly**: Formatted with ANSI blue coloring

## Prerequisites

- `bash` (v4+)
- `curl`
- `jq`

Install dependencies on Fedora/RHEL if needed:
```bash
sudo dnf install -y curl jq
```

## Installation & Usage

Make the script executable:
```bash
chmod +x weather.sh
```

Run directly:
```bash
./weather.sh
```

Or symlink to your local bin directory (e.g. `~/.local/bin`) to run it from anywhere by typing `weather`:
```bash
ln -sf "$(pwd)/weather.sh" ~/.local/bin/weather
weather
```

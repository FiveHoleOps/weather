# Weather CLI (`weather`)

A lightweight Bash script that fetches and displays real-time weather conditions with dynamic color coding.

The terminal output uses a continuous gradient from **Blue** for freezing temperatures (0°F or lower) to **Red** for hot temperatures (100°F or higher), with every temperature in between smoothly incrementing between the two colors.

By default, it shows the weather for Westland, MI (48185), but allows overriding the location with any 5-digit US zip code using the `-z` option.

Powered by [Open-Meteo](https://open-meteo.com/) and [Zippopotam](https://api.zippopotam.us/) (no API keys required).

## Features

- **Temperature Gradient**: 24-bit TrueColor scale transitioning from pure Blue (<= 0°F) to pure Red (>= 100°F) based on the temperature
- **Default Location**: Westland, MI (48185)
- **Zip Code Override**: Use `-z <zip>` to check any 5-digit US zip code
- **Current Conditions**: Weather status (e.g., Clear, Cloudy, Rain, Snow)
- **Temperature & Feels Like**: Current temperature and apparent ("feels like") temperature in °F
- **Daily Extremes**: Today's forecasted high and low temperatures in °F
- **Precipitation**: Current precipitation and rain accumulation in inches
- **Rain Probability**: Today's maximum chance of precipitation (%)
- **Atmospheric Stats**: Relative humidity (%) and wind speed (mph)

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
# Default (Westland, MI - 48185)
./weather.sh

# Specify another zip code
./weather.sh -z 90210
```

Or symlink to your local bin directory (e.g. `~/.local/bin`) to run it from anywhere by typing `weather`:
```bash
ln -sf "$(pwd)/weather.sh" ~/.local/bin/weather
weather
weather -z 10001
```

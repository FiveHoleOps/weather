# Weather CLI (`weather`)

A lightweight Bash script that fetches and displays real-time weather conditions and tomorrow's forecast with dynamic color coding.

## Color Systems

- **Temperature Gradient**: Uses a 24-bit TrueColor scale transitioning from pure **Blue** (<= 0°F) to pure **Red** (>= 100°F), with every temperature in between smoothly incrementing.
- **Comfort Scale (Humidity & Wind)**: Color-coded from **Green** (ideal/comfortable) to **Red** (not ideal/extreme):
  - **Humidity**:
    - `30% - 60%`: **Green** (ideal comfort zone)
    - `20% - 29%` & `61% - 75%`: **Yellow** (moderate)
    - `10% - 19%` & `76% - 85%`: **Orange** (uncomfortable / dry or sticky)
    - `< 10%` & `> 85%`: **Red** (oppressive / extreme)
  - **Wind Speed**:
    - `0 - 12 mph`: **Green** (calm to gentle breeze, ideal)
    - `13 - 19 mph`: **Yellow** (moderate breeze)
    - `20 - 28 mph`: **Orange** (brisk / windy)
    - `29+ mph`: **Red** (high wind / hazardous)

By default, it shows the weather for Westland, MI (48185), but allows overriding the location with any 5-digit US zip code using the `-z` option.

Powered by [Open-Meteo](https://open-meteo.com/) and [Zippopotam](https://api.zippopotam.us/) (no API keys required).

## Features

- **Current Weather**:
  - Sky conditions (e.g. Clear, Overcast, Rain, Snow)
  - Temperature & Apparent ("feels like") temperature in °F (gradient colored)
  - Today's forecasted High / Low in °F (gradient colored)
  - Current precipitation & rain accumulation in inches
  - Daily chance of precipitation (%)
  - Relative humidity (%) with comfort coloring
  - Wind speed (mph) with comfort coloring
- **Tomorrow's Forecast**:
  - Expected conditions
  - High / Low temperatures in °F (gradient colored)
  - Rain probability (%) & expected precipitation amount (in)
  - Average relative humidity (%) with comfort coloring
  - Maximum wind speed (mph) with comfort coloring
- **Zip Code Override**: Use `-z <zip>` to check any 5-digit US zip code

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

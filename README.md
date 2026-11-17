# Weather CLI (`weather`)

A lightweight Bash script that fetches and displays real-time weather conditions and tomorrow's forecast with high-contrast, terminal-optimized color coding.

## Color Systems

- **Temperature Gradient**: Uses high-contrast 24-bit TrueColor with bold formatting, engineered to maintain high luminance and readability across dark and light terminal backgrounds:
  - `<= 0°F`: **Bright Sky Blue**
  - `~25°F`: **Bright Cyan**
  - `~50°F`: **Vibrant Green**
  - `~75°F`: **Bright Gold / Yellow**
  - `>= 100°F`: **Bright Coral Red**
  - *Smooth, high-contrast interpolation for every degree in between (no murky blues or low-contrast purples).*
- **Comfort Scale (Humidity & Wind)**: High-contrast bold scale from **Green** (ideal) to **Coral Red** (not ideal):
  - **Humidity**:
    - `30% - 60%`: **Bright Green** (ideal comfort zone)
    - `20% - 29%` & `61% - 75%`: **Bright Gold** (moderate)
    - `10% - 19%` & `76% - 85%`: **Bright Orange** (uncomfortable / dry or sticky)
    - `< 10%` & `> 85%`: **Bright Coral Red** (oppressive / extreme)
  - **Wind Speed**:
    - `0 - 12 mph`: **Bright Green** (calm to gentle breeze, ideal)
    - `13 - 19 mph`: **Bright Gold** (moderate breeze)
    - `20 - 28 mph`: **Bright Orange** (brisk / windy)
    - `29+ mph`: **Bright Coral Red** (high wind / hazardous)
- **Headings & Labels**:
  - Current Weather Heading: **Bold Cyan**
  - Tomorrow's Forecast Heading: **Bold Gold**
  - Metric Labels: Clean neutral terminal text for crisp contrast

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

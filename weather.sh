#!/usr/bin/env bash
# Script to fetch and display current weather for Westland, MI (48185) in blue text

# ANSI color codes
BLUE='\033[0;34m'
NC='\033[0m' # No Color (reset)

# Coordinates for Westland, MI (48185)
LAT="42.3242"
LON="-83.4002"
URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,snowfall,weather_code,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=America%2FDetroit&forecast_days=1"

response=$(curl -s --max-time 10 "$URL")

if [[ -z "$response" ]]; then
    printf "${BLUE}Error: Unable to fetch weather data for Westland, MI (48185).${NC}\n" >&2
    exit 1
fi

temp=$(echo "$response" | jq -r '.current.temperature_2m')
feels_like=$(echo "$response" | jq -r '.current.apparent_temperature')
humidity=$(echo "$response" | jq -r '.current.relative_humidity_2m')
precip=$(echo "$response" | jq -r '.current.precipitation')
rain=$(echo "$response" | jq -r '.current.rain')
wind=$(echo "$response" | jq -r '.current.wind_speed_10m')
code=$(echo "$response" | jq -r '.current.weather_code')
high=$(echo "$response" | jq -r '.daily.temperature_2m_max[0]')
low=$(echo "$response" | jq -r '.daily.temperature_2m_min[0]')
rain_chance=$(echo "$response" | jq -r '.daily.precipitation_probability_max[0]')

# Map WMO weather code to description
case "$code" in
    0) condition="Clear sky" ;;
    1) condition="Mainly clear" ;;
    2) condition="Partly cloudy" ;;
    3) condition="Overcast / Cloudy" ;;
    45|48) condition="Foggy" ;;
    51|53|55) condition="Drizzle" ;;
    56|57) condition="Freezing drizzle" ;;
    61|63|65) condition="Rain" ;;
    66|67) condition="Freezing rain" ;;
    71|73|75|77) condition="Snow" ;;
    80|81|82) condition="Rain showers" ;;
    85|86) condition="Snow showers" ;;
    95|96|99) condition="Thunderstorm" ;;
    *) condition="Unknown (code $code)" ;;
esac

printf "${BLUE}"
printf "========================================\n"
printf "  Weather for Westland, MI (48185)\n"
printf "========================================\n"
printf "Condition:        %s\n" "$condition"
printf "Temperature:      %s°F (Feels like: %s°F)\n" "$temp" "$feels_like"
printf "Today's High/Low: %s°F / %s°F\n" "$high" "$low"
printf "Rain / Precip:    %s in (Current rain: %s in)\n" "$precip" "$rain"
printf "Rain Chance:      %s%%\n" "$rain_chance"
printf "Humidity:         %s%%\n" "$humidity"
printf "Wind Speed:       %s mph\n" "$wind"
printf "========================================${NC}\n"

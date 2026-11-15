#!/usr/bin/env bash
# Script to fetch and display current weather
# Default location: Westland, MI (48185)
# Supports: -z <5-digit zip> to override location
# Color scale: Dynamic gradient from Blue (<= 0°F) to Red (>= 100°F)

NC='\033[0m' # No Color (reset)
DEFAULT_COLOR='\033[0;34m' # Fallback blue

ZIP="48185"

# Calculate truecolor ANSI code for temperature on a gradient from Blue (<=0) to Red (>=100)
get_temp_color() {
    local raw="$1"
    local t
    t=$(LC_ALL=C printf "%.0f" "$raw" 2>/dev/null || echo 0)
    if (( t <= 0 )); then
        printf '\033[38;2;0;0;255m'
    elif (( t >= 100 )); then
        printf '\033[38;2;255;0;0m'
    else
        local r=$(( (t * 255 + 50) / 100 ))
        local b=$(( ((100 - t) * 255 + 50) / 100 ))
        printf '\033[38;2;%d;0;%dm' "$r" "$b"
    fi
}

usage() {
    printf "Usage: %s [-z <5-digit-zip>] [-h]\n" "$0"
    printf "  -z <zip>   Specify a 5-digit US zip code (default: 48185)\n"
    printf "  -h         Show this help message\n"
    exit 1
}

while getopts "z:h" opt; do
    case "$opt" in
        z)
            ZIP="$OPTARG"
            ;;
        h|*)
            usage
            ;;
    esac
done

if [[ ! "$ZIP" =~ ^[0-9]{5}$ ]]; then
    printf "${DEFAULT_COLOR}Error: Zip code must be a 5-digit number (e.g. 48185).${NC}\n" >&2
    exit 1
fi

if [[ "$ZIP" == "48185" ]]; then
    LAT="42.3242"
    LON="-83.4002"
    CITY="Westland"
    STATE="MI"
else
    geo_data=$(curl -s --max-time 5 "https://api.zippopotam.us/us/${ZIP}")
    LAT=$(echo "$geo_data" | jq -r '.places[0].latitude // empty')
    LON=$(echo "$geo_data" | jq -r '.places[0].longitude // empty')
    CITY=$(echo "$geo_data" | jq -r '.places[0]."place name" // empty')
    STATE=$(echo "$geo_data" | jq -r '.places[0]."state abbreviation" // empty')

    if [[ -z "$LAT" || -z "$LON" ]]; then
        printf "${DEFAULT_COLOR}Error: Could not resolve location for zip code %s.${NC}\n" "$ZIP" >&2
        exit 1
    fi
fi

URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,snowfall,weather_code,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=auto&forecast_days=1"

response=$(curl -s --max-time 10 "$URL")

if [[ -z "$response" ]]; then
    printf "${DEFAULT_COLOR}Error: Unable to fetch weather data for %s, %s (%s).${NC}\n" "$CITY" "$STATE" "$ZIP" >&2
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

# Resolve dynamic colors from gradient
CARD_COLOR=$(get_temp_color "$temp")
TEMP_COLOR=$(get_temp_color "$temp")
FEELS_COLOR=$(get_temp_color "$feels_like")
HIGH_COLOR=$(get_temp_color "$high")
LOW_COLOR=$(get_temp_color "$low")

printf "${CARD_COLOR}"
printf "========================================\n"
printf "  Weather for %s, %s (%s)\n" "$CITY" "$STATE" "$ZIP"
printf "========================================\n"
printf "Condition:        %s\n" "$condition"
printf "Temperature:      %s%s°F%s (Feels like: %s%s°F%s)\n" "$TEMP_COLOR" "$temp" "$CARD_COLOR" "$FEELS_COLOR" "$feels_like" "$CARD_COLOR"
printf "Today's High/Low: %s%s°F%s / %s%s°F%s\n" "$HIGH_COLOR" "$high" "$CARD_COLOR" "$LOW_COLOR" "$low" "$CARD_COLOR"
printf "Rain / Precip:    %s in (Current rain: %s in)\n" "$precip" "$rain"
printf "Rain Chance:      %s%%\n" "$rain_chance"
printf "Humidity:         %s%%\n" "$humidity"
printf "Wind Speed:       %s mph\n" "$wind"
printf "========================================${NC}\n"

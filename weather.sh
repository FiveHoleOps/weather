#!/usr/bin/env bash
# Script to fetch and display current weather & tomorrow's forecast
# Default location: Westland, MI (48185)
# Supports: -z <5-digit zip> to override location
# Color scale:
#   - Headings: Distinct colors (Cyan for Current Weather, Gold/Yellow for Tomorrow)
#   - Temperature: Dynamic gradient from Blue (<= 0°F) to Red (>= 100°F)
#   - Humidity & Wind: Ideal (Green) to Not Ideal (Red)
#   - Labels: Clean neutral terminal text

NC=$'\033[0m' # No Color (reset)
DEFAULT_COLOR=$'\033[0;34m' # Fallback blue

# Heading colors
WEATHER_HEAD_COLOR=$'\033[1;36m'   # Bold Cyan for Current Weather
FORECAST_HEAD_COLOR=$'\033[1;33m'  # Bold Yellow/Gold for Tomorrow's Forecast

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

# Calculate color for humidity: 30-60% ideal (green), extremes are red
get_humidity_color() {
    local raw="$1"
    local h
    h=$(LC_ALL=C printf "%.0f" "$raw" 2>/dev/null || echo 50)
    if (( h >= 30 && h <= 60 )); then
        printf '\033[38;2;46;204;113m'  # Green (Ideal / comfortable)
    elif (( (h >= 20 && h < 30) || (h > 60 && h <= 75) )); then
        printf '\033[38;2;241;196;15m'  # Yellow (Moderate)
    elif (( (h >= 10 && h < 20) || (h > 75 && h <= 85) )); then
        printf '\033[38;2;230;126;34m'  # Orange (Uncomfortable)
    else
        printf '\033[38;2;231;76;60m'   # Red (Poor / oppressive or very dry)
    fi
}

# Calculate color for wind speed: 0-12 mph ideal (green), high wind is red
get_wind_color() {
    local raw="$1"
    local w
    w=$(LC_ALL=C printf "%.0f" "$raw" 2>/dev/null || echo 0)
    if (( w <= 12 )); then
        printf '\033[38;2;46;204;113m'  # Green (Ideal / calm breeze)
    elif (( w <= 19 )); then
        printf '\033[38;2;241;196;15m'  # Yellow (Moderate breeze)
    elif (( w <= 28 )); then
        printf '\033[38;2;230;126;34m'  # Orange (Brisk / windy)
    else
        printf '\033[38;2;231;76;60m'   # Red (High wind / hazardous)
    fi
}

# Map WMO weather code to description
get_weather_desc() {
    case "$1" in
        0) echo "Clear sky" ;;
        1) echo "Mainly clear" ;;
        2) echo "Partly cloudy" ;;
        3) echo "Overcast / Cloudy" ;;
        45|48) echo "Foggy" ;;
        51|53|55) echo "Drizzle" ;;
        56|57) echo "Freezing drizzle" ;;
        61|63|65) echo "Rain" ;;
        66|67) echo "Freezing rain" ;;
        71|73|75|77) echo "Snow" ;;
        80|81|82) echo "Rain showers" ;;
        85|86) echo "Snow showers" ;;
        95|96|99) echo "Thunderstorm" ;;
        *) echo "Unknown (code $1)" ;;
    esac
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
    printf "%sError: Zip code must be a 5-digit number (e.g. 48185).%s\n" "${DEFAULT_COLOR}" "${NC}" >&2
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
        printf "%sError: Could not resolve location for zip code %s.%s\n" "${DEFAULT_COLOR}" "$ZIP" "${NC}" >&2
        exit 1
    fi
fi

URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,snowfall,weather_code,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,weather_code,wind_speed_10m_max,relative_humidity_2m_mean&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=auto&forecast_days=2"

response=$(curl -s --max-time 10 "$URL")

if [[ -z "$response" ]]; then
    printf "%sError: Unable to fetch weather data for %s, %s (%s).%s\n" "${DEFAULT_COLOR}" "$CITY" "$STATE" "$ZIP" "${NC}" >&2
    exit 1
fi

# Current weather metrics
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

condition=$(get_weather_desc "$code")

# Tomorrow forecast metrics
tomorrow_code=$(echo "$response" | jq -r '.daily.weather_code[1]')
tomorrow_high=$(echo "$response" | jq -r '.daily.temperature_2m_max[1]')
tomorrow_low=$(echo "$response" | jq -r '.daily.temperature_2m_min[1]')
tomorrow_rain_chance=$(echo "$response" | jq -r '.daily.precipitation_probability_max[1]')
tomorrow_precip=$(echo "$response" | jq -r '.daily.precipitation_sum[1]')
tomorrow_wind=$(echo "$response" | jq -r '.daily.wind_speed_10m_max[1]')
tomorrow_humidity=$(echo "$response" | jq -r '.daily.relative_humidity_2m_mean[1]')

tomorrow_condition=$(get_weather_desc "$tomorrow_code")

# Resolve dynamic temperature colors (Blue <= 0 to Red >= 100)
TEMP_COLOR=$(get_temp_color "$temp")
FEELS_COLOR=$(get_temp_color "$feels_like")
HIGH_COLOR=$(get_temp_color "$high")
LOW_COLOR=$(get_temp_color "$low")

TOMORROW_HIGH_COLOR=$(get_temp_color "$tomorrow_high")
TOMORROW_LOW_COLOR=$(get_temp_color "$tomorrow_low")

# Resolve ideal (green) to unideal (red) colors for humidity & wind
HUMIDITY_COLOR=$(get_humidity_color "$humidity")
WIND_COLOR=$(get_wind_color "$wind")
TOMORROW_HUMIDITY_COLOR=$(get_humidity_color "$tomorrow_humidity")
TOMORROW_WIND_COLOR=$(get_wind_color "$tomorrow_wind")

# Output display
printf "%s%s\n" "${WEATHER_HEAD_COLOR}" "========================================"
printf "  Weather for %s, %s (%s)\n" "$CITY" "$STATE" "$ZIP"
printf "%s%s\n" "${WEATHER_HEAD_COLOR}" "========================================"
printf "%s" "${NC}"
printf "Condition:        %s\n" "$condition"
printf "Temperature:      %s%s°F%s (Feels like: %s%s°F%s)\n" "$TEMP_COLOR" "$temp" "$NC" "$FEELS_COLOR" "$feels_like" "$NC"
printf "Today's High/Low: %s%s°F%s / %s%s°F%s\n" "$HIGH_COLOR" "$high" "$NC" "$LOW_COLOR" "$low" "$NC"
printf "Rain / Precip:    %s in (Current rain: %s in)\n" "$precip" "$rain"
printf "Rain Chance:      %s%%\n" "$rain_chance"
printf "Humidity:         %s%s%%%s\n" "$HUMIDITY_COLOR" "$humidity" "$NC"
printf "Wind Speed:       %s%s mph%s\n" "$WIND_COLOR" "$wind" "$NC"
printf "%s%s\n" "${FORECAST_HEAD_COLOR}" "----------------------------------------"
printf "  Tomorrow's Forecast\n"
printf "%s%s\n" "${FORECAST_HEAD_COLOR}" "----------------------------------------"
printf "%s" "${NC}"
printf "Condition:        %s\n" "$tomorrow_condition"
printf "High / Low:       %s%s°F%s / %s%s°F%s\n" "$TOMORROW_HIGH_COLOR" "$tomorrow_high" "$NC" "$TOMORROW_LOW_COLOR" "$tomorrow_low" "$NC"
printf "Rain Chance:      %s%% (%s in)\n" "$tomorrow_rain_chance" "$tomorrow_precip"
printf "Avg Humidity:     %s%s%%%s\n" "$TOMORROW_HUMIDITY_COLOR" "$tomorrow_humidity" "$NC"
printf "Max Wind Speed:   %s%s mph%s\n" "$TOMORROW_WIND_COLOR" "$tomorrow_wind" "$NC"
printf "%s%s%s\n" "${WEATHER_HEAD_COLOR}" "========================================" "${NC}"

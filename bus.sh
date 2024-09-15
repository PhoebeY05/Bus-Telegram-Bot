#!/bin/bash

# Replace these with your actual Telegram bot token and chat ID
TELEGRAM_BOT_TOKEN=?
CHAT_ID=?
TELEGRAM_API_URL="https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage"

# Register at https://ipapi.com/ to obtain API key
KEY=? 
host_ipv6=? # Get from  https://ipapi.com/quickstart -> Step 2: API Endpoints -> Make API Request

# Function to get distance between two coordinates
distance() {
    local lat1="$1"
    local lon1="$2"

    # Get the latitude and longitude of the current location
    latitude=$(curl -s "http://api.ipapi.com/$host_ipv6?access_key=$KEY" | jq -r ".latitude")
    longitude=$(curl -s "http://api.ipapi.com/$host_ipv6?access_key=$KEY" | jq -r ".longitude")

    # Function to convert degrees to radians
    deg2rad() {
        local degrees="$1"
        # Remove any extraneous whitespace from the input
        degrees=$(echo "$degrees" | tr -d '[:space:]')
        # Convert degrees to radians using bc
        echo "scale=15; $degrees * 4 * a(1) / 180" | bc -l
    }

    # Convert string to number
    latitude=$(echo "scale=10; $latitude" | bc)
    longitude=$(echo "scale=10; $longitude" | bc)

    # Convert degrees to radians
    lat1_rad=$(deg2rad "$lat1")
    lon1_rad=$(deg2rad "$lon1")
    lat2_rad=$(deg2rad "$latitude")
    lon2_rad=$(deg2rad "$longitude")


    # Differences in coordinates
    delta_lat=$(echo "scale=15; $lat2_rad - $lat1_rad" | bc -l)
    delta_lon=$(echo "scale=15; $lon2_rad - $lon1_rad" | bc -l)

    # Haversine formula
    a=$(echo "scale=15; s($delta_lat / 2)^2 + c($lat1_rad) * c($lat2_rad) * s($delta_lon / 2)^2" | bc -l)
    c=$(echo "scale=15; 2 * a(sqrt($a) / sqrt(1 - $a))" | bc -l)


    # Earth's radius in kilometers
    R=6371

    # Distance calculation
    distance=$(echo "scale=15; $R * $c" | bc -l)
    echo "$distance"
}

# Create coordinates.json to store bus stop latitudes and longitudes
latitude_int=$(cat coordinates.json | jq -r ".interchange.lat")
longitude_int=$(cat coordinates.json | jq -r ".interchange.lng")
latitude_home=$(cat coordinates.json | jq -r ".home.lat")
longitude_home=$(cat coordinates.json | jq -r ".home.lng")

# Calculate distances
distance_home=$(distance "$latitude_home" "$longitude_home")
distance_int=$(distance "$latitude_int" "$longitude_int")

# Choose bus stop to check for based on location of host
if (( $(echo "$distance_home < $distance_int" | bc -l) )); then
    place=? # User-defined name of bus stop
    id=? # ID of bus stop
    index=? # Index of bus in bus stop (Obtained from observing result of API call)
else 
    place="? Interchange"
    id=?
    index=?
fi

# Replace this with your actual curl command that fetches the JSON response
response=$(curl -s "https://arrivelah2.busrouter.sg/?id=$id")

# Extract the 'time' field of the next bus using jq
next_bus_time=$(echo "$response" | jq -r ".services[$index].next.time")

# Convert current time and the bus time to epoch for comparison
current_time=$(date +%s)
bus_arrival_time=$(gdate -d "$next_bus_time" +%s)

# Calculate time difference in seconds
time_diff=$((bus_arrival_time - current_time))

# Convert time difference to minutes and seconds
minutes=$((time_diff / 60))
seconds=$((time_diff % 60))

if [ "$time_diff" -gt 0 ]; then
    message="Bus number ? will arrive in $minutes minutes and $seconds seconds at $place."
else
    message="Bus number ? has already arrived or will arrive shortly."
fi

curl -s -X POST $TELEGRAM_API_URL \
    -d chat_id=$CHAT_ID \
    -d text="$message" > /dev/null
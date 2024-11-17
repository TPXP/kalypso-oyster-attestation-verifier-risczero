#!/bin/bash
set -e

sleep 5

# Source the environment variables
if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
else
    echo "/app/.env file not found."
    exit 1
fi

# Function to get ETH balance
get_eth_balance() {
    ADDRESS="0x0000000000000000000000000000000000000000"
    RPC_URL="https://eth.llamarpc.com"

    # Create the JSON-RPC payload
    JSON_PAYLOAD=$(cat <<EOF
{
    "jsonrpc":"2.0",
    "method":"eth_getBalance",
    "params":["$ADDRESS", "latest"],
    "id":1
}
EOF
)

    # Make the JSON-RPC request with a 10-second timeout
    if RESPONSE=$(curl -s --max-time 10 -X POST \
        -H "Content-Type: application/json" \
        --data "$JSON_PAYLOAD" \
        "$RPC_URL"); then
        echo "ETH balance response:"
        echo "$RESPONSE"
    else
        echo "Failed to retrieve ETH balance."
    fi
}

# Get and display the ETH balance
get_eth_balance

# Execute the attestation prover
RUST_BACKTRACE=full /app/kalypso-attestation-prover

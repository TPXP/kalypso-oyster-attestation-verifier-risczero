#!/bin/bash
set -e

# Source the environment variables
if [ -f /app/.env ]; then
    export $(grep -v '^#' /app/.env | xargs)
else
    echo "/app/.env file not found."
    exit 1
fi

# Execute the attestation prover
/app/kalypso-attestation-prover

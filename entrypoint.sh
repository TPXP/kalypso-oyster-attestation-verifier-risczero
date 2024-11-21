#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

export CHAIN_ID="421614"
export PROOF_MARKETPLACE_ADDRESS="0xfa2AAcA897C4AB956625B72ac678b3CB5450a154"
export GENERATOR_REGISTRY_ADDRESS="0xdC33E074d2b055171e56887D79678136B4505Dec"
export ENTITY_KEY_REGISTRY_ADDRESS="0x457d42573096b339ba48be576e9db4fc5f186091"
export START_BLOCK="96699799"
export MARKET_ID="3"

# Function to display usage instructions
usage() {
  echo "Usage: $0 {register-join|benchmark|test-connection|run-prover}"
  echo
  echo "Options:"
  echo "  register-join     Register and join the network"
  echo "  benchmark         Run benchmark tests"
  echo "  test-connection   Test network connection"
  echo "  run-prover        Execute the prover service"
  exit 1
}

# Cleanup function to handle termination
cleanup() {
  echo "Received termination signal. Cleaning up..."
  
  # Add any necessary cleanup commands here
  # For example, kill background processes if any
  # pkill -P $$  # Kills all child processes spawned by this script
  
  exit 0
}

# Trap SIGINT (Ctrl+C) and SIGTERM
trap cleanup SIGINT SIGTERM

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
  echo "Error: No option provided."
  usage
fi

# Capture the first argument as the operation
OPERATION="$1"

# Execute based on the selected operation
case "$OPERATION" in
  register-join)
    export DECLARED_COMPUTE=10
    export COMPUTE_PER_REQUEST=10
    export PROPOSED_TIME=10
    
    echo "Starting registration and joining process..."
    # Add your registration and join commands below
    OPERATION_NAME="Register" ./kalypso-cli &
    REGISTER_PID=$!
    OPERATION_NAME="Join Marketplace" ./kalypso-cli &
    JOIN_PID=$!
    # Wait for background processes to finish
    wait $REGISTER_PID $JOIN_PID
    ;;
  
  benchmark)
    echo "Running benchmark tests..."
    # Add your benchmark commands below
    RUST_BACKTRACE=1 ./benchmark &
    BENCHMARK_PID=$!
    wait $BENCHMARK_PID
    ;;
  
  test-connection)
    echo "Testing network connection..."
    # Add your connection test commands below
    ./host --url http://3.110.146.109:1500/attestation/raw &
    HOST_PID=$!
    wait $HOST_PID
    ;;
  
  run-prover)
    export MAX_PARALLEL_PROOFS="1"
    export IVS_URL="http://3.110.146.109:3030"
    export PROVER_URL="http://localhost:3030/api/generateProof"
    
    echo "Executing the prover service..."
    # Add your prover execution commands below
    ./kalypso-attestation-prover &
    PROVER_PID=$!
    wait $PROVER_PID
    ;;
  
  *)
    echo "Error: Invalid option '$OPERATION'."
    usage
    ;;
esac

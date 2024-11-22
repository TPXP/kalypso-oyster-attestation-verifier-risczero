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
  echo "  symbiotic-stake   Request Symbiotic Stake"
  echo "  native-stake      Stake your own tokens"
  echo "  claim-rewards     Claim Rewards"
  echo "  discard-request   Discard Request"
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
  
  symbiotic-stake)
    echo "Starting symbiotic stake request..."
    export SYMBIOTIC_CHAIN_ID=17000
    export VAULT_OPT_IN_SERVICE="0x95CC0a052ae33941877c9619835A233D21D57351"
    export VAULT_ADDRESS="0x470696186e679b46632EF9702F077D6848bf1bd1"
    export NETWORK_OPT_IN_SERVICE="0x58973d16FFA900D11fC22e5e2B6840d9f7e13401"
    export NETWORK_ADDRESS="0xa2024540267e3366B1D3381285dd11A1B45928df"
    
    OPERATION_NAME="Request Symbiotic Stake" ./kalypso-cli &
    SYM_PID=$!
    # Wait for background processes to finish
    wait $SYM_PID
    ;;

  native-stake)
    echo "Native Staking"
    export NATIVE_STAKING_ADDRESS="0xe9d2Bcc597f943ddA9EDf356DAC7C6A713dDE113"
    export STAKING_TOKEN="0xB5570D4D39dD20F61dEf7C0d6846790360b89a18"

    OPERATION_NAME="Native Stake" ./kalypso-cli &
    NAT_PID=$!
    # Wait for background processes to finish
    wait $NAT_PID
    ;;

  claim-rewards)
    echo "Claim Rewards"
    export PAYMENT_TOKEN="0x8230d71d809718132C2054704F5E3aF1b86B669C"

    OPERATION_NAME="Claim Rewards" ./kalypso-cli &
    CLAIM_ID=$!
    # Wait for background processes to finish
    wait $CLAIM_ID
    ;;

  discard-request)
    echo "Discard Request"

    OPERATION_NAME="Discard Request" ./kalypso-cli &
    D_ID=$!
    # Wait for background processes to finish
    wait $D_ID
    ;;

  *)
    echo "Error: Invalid option '$OPERATION'."
    usage
    ;;
esac

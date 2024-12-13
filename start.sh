#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to verify the existence of required binaries
check_all_binaries_exist() {
    echo "Verifying the presence of required binaries..."

    # Define the list of required binaries
    REQUIRED_BINARIES=("test-connection" "benchmark" "kalypso-attestation-prover" "kalypso-cli")

    # Initialize an array to hold any missing binaries
    MISSING_BINARIES=()

    # Iterate over each required binary and check its existence
    for binary in "${REQUIRED_BINARIES[@]}"; do
        if [ ! -f "./$binary" ]; then
            MISSING_BINARIES+=("$binary")
        fi
    done

    # If there are missing binaries, display an error and exit
    if [ "${#MISSING_BINARIES[@]}" -ne 0 ]; then
        echo "Error: The following required binaries are missing in the current directory:"
        for missing in "${MISSING_BINARIES[@]}"; do
            echo "  - $missing"
        done
        echo "Please ensure that all build steps completed successfully."
        exit 1
    else
        echo "All required binaries are present in the current directory."
    fi
}

# Function to display usage instructions
usage() {
  echo "Usage: $0 {register-join|benchmark|test-connection|run-prover|symbiotic-stake|native-stake|claim-rewards|discard-request|read-stake|symbiotic-register}"
  echo
  echo "Options:"
  echo "  benchmark            Run benchmark tests"
  echo "  claim-rewards        Claim Rewards"
  echo "  discard-request      Discard Request"
  echo "  native-stake         Stake your own tokens"
  echo "  read-stake           Read Stake data"
  echo "  register-join        Register and join the network"
  echo "  run-prover           Execute the prover service"
  echo "  symbiotic-register   Register Operator with symbiotic"
  echo "  symbiotic-stake      Request Symbiotic Stake"
  echo "  test-connection      Test network connection"
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

# Verify binaries before proceeding
check_all_binaries_exist

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
  echo "Error: No option provided."
  usage
fi

# Capture the first argument as the operation
OPERATION="$1"

# Export necessary environment variables
export CHAIN_ID="421614"
export PROOF_MARKETPLACE_ADDRESS="0xfa2AAcA897C4AB956625B72ac678b3CB5450a154"
export GENERATOR_REGISTRY_ADDRESS="0xdC33E074d2b055171e56887D79678136B4505Dec"
export ENTITY_KEY_REGISTRY_ADDRESS="0x457d42573096b339ba48be576e9db4fc5f186091"
export START_BLOCK="106483690"
export MARKET_ID="3"

# Execute based on the selected operation
case "$OPERATION" in
  register-join)
    # Temporarily disable exit on error for multistep process
    set +e

    export DECLARED_COMPUTE=10
    export COMPUTE_PER_REQUEST=10
    export PROPOSED_TIME=10
    
    echo "Starting registration and joining process..."
    
    # Run the first operation
    OPERATION_NAME="Register" ./kalypso-cli
    REGISTER_STATUS=$?
    echo "Registration process completed with exit status $REGISTER_STATUS"
    
    # Run the second operation regardless of the first one's result
    OPERATION_NAME="Join Marketplace" ./kalypso-cli
    JOIN_STATUS=$?
    echo "Join Marketplace process completed with exit status $JOIN_STATUS"
    
    # Re-enable exit on error
    set -e
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
    ./test-connection --url http://3.110.146.109:1500/attestation/raw &
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
    export NETWORK_OPT_IN_SERVICE="0x58973d16FFA900D11fC22e5e2B6840d9f7e13401"
    
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

  symbiotic-register)
    echo "Register Operator with symbiotic"

    export SYMBIOTIC_CHAIN_ID=17000
    export SYMBIOTIC_OPERATOR_REGISTRY=0x6F75a4ffF97326A00e52662d82EA4FdE86a2C548

    OPERATION_NAME="Symbiotic Operator Register" ./kalypso-cli &
    S_ID=$!
    # Wait for background processes to finish
    wait $S_ID
    ;;

  read-stake)
    echo "Read Operator Stake data"
    export INDEXER_URL="https://kalypso-symbiotic-indexer.justfortesting.me"

    OPERATION_NAME="Read Stake Data" ./kalypso-cli &
    S_ID=$!
    # Wait for background processes to finish
    wait $S_ID
    ;;

    set-commission)
    echo "Set Operator Commission"

    OPERATION_NAME="Set Operator Reward Commission" ./kalypso-cli &
    S_ID=$!
    # Wait for background processes to finish
    wait $S_ID
    ;;

  *)
  

    echo "Error: Invalid option '$OPERATION'."
    usage
    ;;
esac

echo "Bootstrap completed successfully."

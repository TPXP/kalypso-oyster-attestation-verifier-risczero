![Marlin Oyster Logo](./logo.svg)

# Attestation Verifier - RiscZero

This repository implements a RiscZero based AWS Nitro Enclave attestation verifier.

While it produces zero false positives, it does not aim to produce zero false negatives, i.e. it could reject _theoretically_ valid attestations. Instead, it asserts specific attestation formats that are _actually_ used in order to optimize proving time. It also does not verify any extensions in the certificates as it was deemed unnecessary.

## Build

Install the RiscZero tooling before proceeding further.

Note: Requires CUDA by default. It is possible to disable CUDA by disabling the relevant feature in `host/Cargo.toml`, but the proof generation process could take hours on a CPU. 

```bash
cargo build --release
```

### Reproducible builds

Reproducible builds are enabled for the guest to produce a consistent GUEST_ID.

Expected GUEST_ID: 0x785ecdc7494dcdb0ee09574ad5554c79d8c6b99e8cb11dba5cf3c05a0e71d9ec

## Usage

```bash
$ ./target/release/host --help
GUEST: 0x785ecdc7494dcdb0ee09574ad5554c79d8c6b99e8cb11dba5cf3c05a0e71d9ec
Usage: host --url <URL>

Options:
  -u, --url <URL>  
  -h, --help       Print help
  -V, --version    Print version
```

It takes in a URL to an attestation server producing binary attestations. The attestation server should include a 64 byte public key in the attestation.

## Journal format

The journal contains bytes in the following order:
- 8 byte timestamp in milliseconds from the attestation
- 48 byte PCR0
- 48 byte PCR1
- 48 byte PCR2
- 48 byte public key from the root certificate
- 64 byte public key from the attestation
- 2 byte length of the user data
- N byte user data

## Directory Structure

```text
project_name
├── Cargo.toml
├── host
│   ├── Cargo.toml                     <-- [Disable CUDA here]
│   └── src
│       └── main.rs                    <-- [Host code goes here]
└── methods
    ├── Cargo.toml
    ├── build.rs                       <-- [Reproducible guest builds stuff here]
    ├── guest
    │   ├── Cargo.toml
    │   └── src
    │       └── method_name.rs         <-- [Guest code goes here]
    └── src
        └── lib.rs
```

## Kalypso Prover
#### Note: _To manage regular operation of kalypso-cli it is recommended to install [kalypso-cli](#kalypso-cli-documentation)_
Provers can generate proofs or attestation requests on kalypso and earn rewards.

```bash
touch .env
```
`.env` file should contain

```
GENERATOR_ADDRESS=<<generatorAddress>>
GAS_KEY=<<gas key>>
MARKET_ID=3
HTTP_RPC_URL=https://arb-sepolia.g.alchemy.com/v2/<<apikey>>
PROOF_MARKETPLACE_ADDRESS="0xfa2AAcA897C4AB956625B72ac678b3CB5450a154"
GENERATOR_REGISTRY_ADDRESS="0xdC33E074d2b055171e56887D79678136B4505Dec"
START_BLOCK=92423485
CHAIN_ID=421614
MAX_PARALLEL_PROOFS=1
IVS_URL=http://3.110.146.109:3030
PROVER_URL=http://localhost:3030/api/generateProof
```

#### Build the prover
```rust
cargo build --release
```

#### Benchmark the prover
This is should a proof for an attestation. It should take around 12-13 mins to generate the proof.
```sh
./target/release/benchmark
```

#### Run the prover
The prover automatically detect the requests assigned to the your `generatorAddress` and submit proofs to kalypso and earns rewards.
```bash
./target/release/kalypso-attestation-prover
```

### Kalypso CLI Documentation

The `kalypso-cli` is an optional command-line interface (CLI) tool that provides an interactive way to perform various operations related to the Kalypso ecosystem. This guide explains how to build and run the `kalypso-cli` tool.

---

### Step 1: Download the Kalypso Monorepo

Open a terminal and clone the `kalypso-unified` repository:

```sh
git clone https://github.com/marlinprotocol/kalypso-unified
cd kalypso-unified
git checkout symbotic-bindings
```

---

### Step 2: Build the CLI Tool

Ensure you are using a `stable` Rust toolchain to build the `kalypso-cli`. Run the following commands:

```sh
rm -rf .cargo
cargo build --release --bin kalypso-cli
```

This command builds the CLI tool in release mode.

---

### Step 3: Run the CLI Tool

Once the build is complete, you can run the `kalypso-cli` tool. It will prompt you to select an operation to perform. You can either input values interactively or use environment variables to predefine them.

#### Example:

```sh
./target/release/kalypso-cli
```

When executed, the CLI will display a list of operations:

```sh
kalypso@kalypso:~/kalypso-unified$ ./target/release/kalypso-cli 
? Select an operation ›
❯ Add IVS Key
  Benchmark Prover
  Claim Rewards
  Compute PCRs
  Create Marketplace
  Create Proof Request (confidential market)
  Create Proof Request (non confidential market)
  Discard Request
  Join Marketplace
  Leave Marketplace
  Load Generator Config
  Native Stake
  Non-Confidential Market PCRS
  Read Attestation
  Read Proof Bytes
  Register
  Request Symbiotic Stake
  Request To Leave Marketplace
  Start Enclave Program
  Stop Enclave Program
  Test Enclave Connection
  Update Encryption Key
  Whitelist IVS Image
  Whitelist Prover Image
```

## License
This repository is licensed under the GNU AGPLv3 or any later version. See [LICENSE.txt](./LICENSE.txt).

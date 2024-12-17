![Marlin Oyster Logo](./logo.svg)

# Attestation Verifier - RiscZero

This repository implements a RiscZero based AWS Nitro Enclave attestation verifier.

While it produces zero false positives, it does not aim to produce zero false negatives, i.e. it could reject _theoretically_ valid attestations. Instead, it asserts specific attestation formats that are _actually_ used in order to optimize proving time. It also does not verify any extensions in the certificates as it was deemed unnecessary.

## Build
Build the executables

1.
```sh
chmod +x bootstrap.sh
```

2. Clean the build
```sh
./bootstrap.sh clean
```

3 a. Build for GPU (recommended)
```sh
chmod +x bootstrap.sh
./bootstrap.sh --gpu
```

3 b. Build for CPU (recommended)
You can still participate and challenge invalid attestation requests to earn rewards
```sh
./bootstrap.sh --cpu
```

4. Run prover
```sh
chmod +x start.sh
```

```sh
./start.sh run-prover
```
#!/bin/sh
nitro-cli terminate-enclave --all
nitro-cli run-enclave --cpu-count 6 --memory 5000 --eif-path nitro-enclave.eif --enclave-cid 88 --debug-mode
nitro-cli console --enclave-id $(nitro-cli describe-enclaves | jq -r ".[0].EnclaveID")
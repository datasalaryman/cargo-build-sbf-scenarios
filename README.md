# Simulating cargo-build-sbf user installation scenarios

This repository creates several docker images for testing a change to the Solana CLI installation. 

We need to see if changing the Agave active_release/bin/cargo-build-sbf binary to be a symlink to the ~/.cargo/bin directory will still work without any issues in the following scenarios:

Version of Solana CLI with this change is contained in this PR - https://github.com/anza-xyz/agave/pull/15415

## Scenarios
1. The user installed the cargo-build-sbf binary via cargo, then installed the Solana CLI, then eventually installs newer version of Solana CLI that contains the change in the PR
2. The user installed the Solana CLI first and then installed the cargo-build-sbf via cargo afterwards, then eventually installs the newer version of the Solana CLI that contains the change in the PR
3. The user has never installed the Solana CLI and is installing the newer version that contains the change in the PR

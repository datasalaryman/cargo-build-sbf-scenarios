# Simulating cargo-build-sbf user installation scenarios

This repository creates several docker images for testing a change to the Solana CLI installation. 

We need to see if changing the Agave active_release/bin/cargo-build-sbf binary to be a symlink to the ~/.cargo/bin directory will still work without any issues in the following scenarios:

Version of Solana CLI with this change is contained in this PR - https://github.com/anza-xyz/agave/pull/15415

## Scenarios
1. The user installed the cargo-build-sbf binary via cargo, then installed the Solana CLI, then eventually installs newer version of Solana CLI that contains the change in the PR
2. The user installed the Solana CLI first and then installed the cargo-build-sbf via cargo afterwards, then eventually installs the newer version of the Solana CLI that contains the change in the PR
3. The user has never installed the Solana CLI and is installing the newer version that contains the change in the PR

## Individual installation methods

#### cargo-build-sbf

```bash
cargo install cargo-build-sbf --force
```

#### Solana CLI

```bash
sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"
```

#### Solana CLI from PR

PR #15415 changes Agave's source installation script, so it must be tested by
checking out the PR commit and running that script. The scenarios use the
following reduced build, which installs the end-user CLI binaries and platform
tools while skipping validator and development binaries:

```bash
git clone https://github.com/anza-xyz/agave.git
cd agave
git checkout a7c5efc84bdd645574185bc4b6efc3e0cd716851
./scripts/cargo-install-all.sh \
  --no-build-dcou-bins \
  --no-build-deprecated-bins \
  --no-build-dev-bins \
  --no-build-validator-bins \
  --no-spl-token \
  "$HOME/.local/share/solana/install/releases/pr-15415"
```


## Running the scenarios

Each scenario runs as an unprivileged user in a clean Docker container. The logs
show the `PATH` entries, every matching command on `PATH`, the selected and real
binary paths, symlink details, and the versions reported by `solana`,
`cargo-build-sbf`, and `cargo-test-sbf` after every installation step. Once the
scenario reaches its final state, it also uses the selected `cargo-build-sbf`
binary to build the minimal Anchor program in `programs/hello-solana`.

PR #15415 does not have a published Agave release artifact. The candidate step
therefore downloads its exact commit and runs `scripts/cargo-install-all.sh`
from source. This directly exercises the PR behavior that installs
`cargo-build-sbf` into `$CARGO_HOME/bin` and creates symlinks in the release's
`bin` directory.

Prerequisite: Docker with support for Linux/amd64 containers.

```sh
make scenario-1
make scenario-2
make scenario-3

# Run all three in order
make all
```

Defaults can be overridden on the command line:

```sh
make scenario-1 \
  OLD_SOLANA_VERSION=v4.2.1 \
  MANUAL_CARGO_BUILD_SBF_VERSION=4.2.0 \
  CANDIDATE_CARGO_BUILD_SBF_VERSION=4.4.0 \
  AGAVE_PR_COMMIT=a7c5efc84bdd645574185bc4b6efc3e0cd716851
```

The downloads and Rust compilation happen when the container runs. Building
Agave from source is resource intensive and can take significant time and disk
space. Use `make clean` to remove the three scenario images.

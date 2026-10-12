#!/usr/bin/env bash
set -euo pipefail
source /workspace/scripts/common.sh

section "Scenario 1: cargo, old CLI, candidate CLI"
diagnostics "Initial state"
install_cargo_build_sbf "$MANUAL_CARGO_BUILD_SBF_VERSION"
diagnostics "After manual cargo install"
install_solana_release "$OLD_SOLANA_VERSION"
diagnostics "After old Solana CLI install"
install_candidate_release
diagnostics "Final state after candidate CLI update"
build_anchor_program

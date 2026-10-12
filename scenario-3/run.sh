#!/usr/bin/env bash
set -euo pipefail
source /workspace/scripts/common.sh

section "Scenario 3: fresh candidate CLI install"
diagnostics "Initial state"
install_candidate_release
diagnostics "Final state after fresh candidate CLI install"
build_anchor_program

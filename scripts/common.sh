#!/usr/bin/env bash

set -euo pipefail

: "${OLD_SOLANA_VERSION:=v4.2.1}"
: "${MANUAL_CARGO_BUILD_SBF_VERSION:=4.2.0}"
: "${CANDIDATE_CARGO_BUILD_SBF_VERSION:=4.4.0}"
: "${AGAVE_PR_COMMIT:=a7c5efc84bdd645574185bc4b6efc3e0cd716851}"
: "${AGAVE_REPOSITORY:=https://github.com/anza-xyz/agave.git}"

SOLANA_INSTALL_DIR="${SOLANA_INSTALL_DIR:-$HOME/.local/share/solana/install}"
ACTIVE_RELEASE="$SOLANA_INSTALL_DIR/active_release"

section() {
  printf '\n\n========== %s ==========\n' "$*"
}

install_solana_release() {
  local version="$1"
  local installer

  section "Installing Solana CLI $version"
  installer="$(mktemp)"
  trap 'rm -f "$installer"' RETURN
  curl --fail --location --retry 3 --show-error --silent \
    https://release.anza.xyz/stable/install \
    --output "$installer"
  SOLANA_RELEASE="$version" \
    SOLANA_INSTALL_INIT_ARGS="--data-dir $SOLANA_INSTALL_DIR" \
    sh "$installer"
  source "$HOME/.profile"
  rm -f "$installer"
  trap - RETURN
  hash -r
}

install_cargo_build_sbf() {
  local version="$1"

  section "Installing cargo-build-sbf $version with cargo"
  cargo install --locked --force --version "$version" cargo-build-sbf
  hash -r
}

install_candidate_release() {
  local release_dir="$SOLANA_INSTALL_DIR/releases/pr-$AGAVE_PR_COMMIT"
  local source_dir

  section "Installing Solana CLI from PR #15415 ($AGAVE_PR_COMMIT)"
  source_dir="$(mktemp -d)"
  git -C "$source_dir" init --quiet
  git -C "$source_dir" remote add origin "$AGAVE_REPOSITORY"
  git -C "$source_dir" fetch --depth 1 origin "$AGAVE_PR_COMMIT"
  git -C "$source_dir" checkout --quiet FETCH_HEAD

  # Stable branches populate this value before publishing. Pin it here so the
  # scenario remains reproducible while still exercising the PR's install code.
  sed -i \
    "s/^cargoBuildSbfVersion=.*/cargoBuildSbfVersion=$CANDIDATE_CARGO_BUILD_SBF_VERSION/" \
    "$source_dir/scripts/cargo-build-sbf-version.sh"

  rm -rf "$release_dir"
  "$source_dir/scripts/cargo-install-all.sh" \
    --no-build-dcou-bins \
    --no-build-deprecated-bins \
    --no-build-dev-bins \
    --no-build-validator-bins \
    --no-spl-token \
    "$release_dir"

  ln -sfn "$release_dir" "$ACTIVE_RELEASE"
  rm -rf "$source_dir"
  hash -r
}

show_command() {
  local command_name="$1"
  local resolved

  printf '\n-- %s --\n' "$command_name"
  type -a "$command_name" 2>&1 || true
  resolved="$(command -v "$command_name" 2>/dev/null || true)"
  if [[ -z "$resolved" ]]; then
    printf 'selected: <not installed>\n'
    return
  fi
  printf 'selected: %s\n' "$resolved"
  printf 'real path: %s\n' "$(readlink -f "$resolved")"
  ls -l "$resolved"
  "$resolved" --version 2>&1 || true
}

diagnostics() {
  local label="$1"

  section "$label"
  printf 'PATH entries:\n'
  awk -v RS=: '{ printf "  %2d  %s\n", NR, $0 }' <<<"$PATH"
  printf '\nCARGO_HOME: %s\n' "${CARGO_HOME:-$HOME/.cargo}"
  printf 'Solana active release: '
  readlink -f "$ACTIVE_RELEASE" 2>/dev/null || printf '<not installed>\n'
  if [[ -d "$ACTIVE_RELEASE/bin" ]]; then
    printf '\nRelevant active-release entries:\n'
    ls -l "$ACTIVE_RELEASE/bin/solana" \
      "$ACTIVE_RELEASE/bin/cargo-build-sbf" \
      "$ACTIVE_RELEASE/bin/cargo-test-sbf" 2>&1 || true
  fi
  show_command solana
  show_command cargo-build-sbf
  show_command cargo-test-sbf
}

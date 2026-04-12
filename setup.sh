#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Agent Skills Builder — Remote CLI Installer Wrapper
# Usage: curl -fsSL https://raw.githubusercontent.com/anhnt/agents_skills_builder/main/setup.sh | bash -s -- [OPTIONS]
# ============================================================================

REPO="anhnt/agents_skills_builder"
BRANCH="${AGENT_SKILLS_BRANCH:-main}"
TARBALL_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_err()  { echo -e "${RED}✗${NC}  $1"; exit 1; }

# Dependency check
if ! command -v curl >/dev/null 2>&1; then
    log_err "curl is required to run this script. Please install curl and try again."
fi
if ! command -v tar >/dev/null 2>&1; then
    log_err "tar is required to extract the repository. Please install tar and try again."
fi

# Create a temporary directory
TMP_DIR=$(mktemp -d -t agent-skills-XXXXXX)
# Ensure cleanup happens on script exit, even if there's an error
trap 'rm -rf "${TMP_DIR}"' EXIT

log_info "Downloading Agent Skills Builder from ${REPO} (${BRANCH} branch)..."

cd "${TMP_DIR}"

# Download and extract the repository
curl -fsSL "$TARBALL_URL" -o repo.tar.gz || log_err "Failed to download repository tarball."
tar -xzf repo.tar.gz || log_err "Failed to extract tarball."

# Find the extracted root (the tarball structure has a top-level directory like agents_skills_builder-main)
EXTRACTED_DIR=$(find . -maxdepth 1 -mindepth 1 -type d | head -n 1)

if [[ ! -f "${EXTRACTED_DIR}/install.sh" ]]; then
    log_err "Could not locate install.sh inside the downloaded package."
fi

log_info "Executing absolute installation..."
echo ""

# Forward all arguments ("$@") directly to the true local install script
bash "${EXTRACTED_DIR}/install.sh" "$@"

# The EXIT trap will automatically clean up TMP_DIR right after this script finishes.

#!/bin/bash
set -euo pipefail

CWD="$(pwd)"
EDITOR="${EDITOR:-vim}"

{
  test -d "${HOME}/.config/opencode" \
  && test -d "${HOME}/.cache/opencode" \
  && test -d "${HOME}/.local/state/opencode"
} || {
  echo "ERROR! Please run native opencode at least once."
  exit 1
}

# Editor

EDITOR_HOST_PATH=$(which ${EDITOR})

if [[ ! -x "${EDITOR_HOST_PATH}" ]]; then
  echo "ERROR! Editor binary not found at ${EDITOR_HOST_PATH}"
  exit 1
fi

# Starting

docker run --rm -ti --name "opencode-$(basename "${CWD}")-$(date +%Y%m%d-%H%M%S)" \
  -e EDITOR \
  -v "${HOME}/.config/opencode":/home/opencode/.config/opencode \
  -v "${HOME}/.cache/opencode":/home/opencode/.cache/opencode \
  -v "${HOME}/.local/state/opencode":/home/opencode/.local/state/opencode \
  -v "${EDITOR_HOST_PATH}:/usr/bin/$(basename ${EDITOR}):ro" \
  -v "$(pwd)":/work \
  agrrh/opencode-sandbox:latest

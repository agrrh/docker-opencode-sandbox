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

# Env vars to pass into the sandbox.
#
# The list of variable names is configured via SANDBOX_ENV_VARS
# (space-separated). EDITOR is always passed. OPENAI_API_KEY is included
# by default for backwards compatibility.
read -ra ENV_VAR_NAMES <<< "${SANDBOX_ENV_VARS:-OPENAI_API_KEY}"

ENV_ARGS=()
for name in "${ENV_VAR_NAMES[@]}"; do
  [[ -z "$name" ]] && continue
  if [[ -v "$name" ]]; then
    ENV_ARGS+=(-e "$name")
  else
    echo "WARN: env var '$name' is not set; skipping." >&2
  fi
done

# Starting

docker run --rm -ti --name "opencode-$(basename "${CWD}")-$(date +%Y%m%d-%H%M%S)" \
  -e EDITOR \
  ${ENV_ARGS[@]+${ENV_ARGS[@]} } \
  -v "${HOME}/.config/opencode":/home/opencode/.config/opencode \
  -v "${HOME}/.cache/opencode":/home/opencode/.cache/opencode \
  -v "${HOME}/.local/state/opencode":/home/opencode/.local/state/opencode \
  -v "${EDITOR_HOST_PATH}:/usr/bin/$(basename ${EDITOR}):ro" \
  -v "$(pwd)":/work \
  agrrh/opencode-sandbox:latest

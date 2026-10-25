#!/bin/bash
set -euo pipefail

CWD="$(pwd)"

EDITOR="${OPENCODE_SANDBOX_EDITOR:-vim}"
ENV_VARS="${OPENCODE_SANDBOX_ENV_VARS:-OPENAI_API_KEY}"
DEFAULT_PROVIDER="${OPENCODE_SANDBOX_DEFAULT_PROVIDER:-}"
DEFAULT_MODEL="${OPENCODE_SANDBOX_DEFAULT_MODEL:-}"

#
# Sanity checks
#

{
  test -d "${HOME}/.config/opencode" \
  && test -d "${HOME}/.cache/opencode" \
  && test -d "${HOME}/.local/state/opencode"
} || {
  echo "ERROR! Please run native opencode at least once."
  exit 1
}

#
# Select default provider/model, if unset
#

if [ -z "${DEFAULT_PROVIDER}" ]; then
  DEFAULT_PROVIDER=$(opencode models \
    | cut -d'/' -f1 \
    | uniq \
    | fzf --header "Select default provider:" --select-1
  )
fi

if [ -z "${DEFAULT_MODEL}" ]; then
  DEFAULT_MODEL=$(opencode models \
    | grep "^${DEFAULT_PROVIDER}/" \
    | cut -d'/' -f2- \
    | fzf --header "Select default model:" --select-1
  )
fi

#
# Editor
#

EDITOR_HOST_PATH=$(which ${EDITOR})
EDITOR_BASENAME=$(basename ${EDITOR})

if [[ ! -x "${EDITOR_HOST_PATH}" ]]; then
  echo "ERROR! Editor binary not found at ${EDITOR_HOST_PATH}"
  exit 1
fi

# Env vars to pass into the sandbox.
#
# The list of variable names is configured via SANDBOX_ENV_VARS
# (space-separated). EDITOR is always passed. OPENAI_API_KEY is included
# by default for backwards compatibility.
read -ra ENV_VAR_NAMES <<< "${ENV_VARS:-OPENAI_API_KEY}"

ENV_ARGS=()
for name in "${ENV_VAR_NAMES[@]}"; do
  [[ -z "$name" ]] && continue
  if [[ -v "$name" ]]; then
    ENV_ARGS+=(-e "$name")
  else
    echo "WARN: env var '$name' is not set; skipping." >&2
  fi
done

# Optional one-shot task.
#
# With a task, opencode runs it and exits (non-interactive,
# `opencode run "..."`). Without one, opencode starts interactive
# --auto mode (the default CMD in the Dockerfile).
RUN_ARGS=()
if [[ "$#" -gt 0 ]]; then
  RUN_ARGS=("opencode" "run" "--auto" "--thinking" "--model" "${DEFAULT_PROVIDER}/${DEFAULT_MODEL}" "$*")
  echo "Running opencode in task mode: $*" >&2
fi

#
# Starting
#

docker run --rm -ti --name "opencode-$(basename "${CWD}")-$(date +%Y%m%d-%H%M%S)" \
  -e EDITOR \
  ${ENV_ARGS[@]+${ENV_ARGS[@]} } \
  -v "${HOME}/.config/opencode":/home/opencode/.config/opencode \
  -v "${HOME}/.cache/opencode":/home/opencode/.cache/opencode \
  -v "${HOME}/.local/state/opencode":/home/opencode/.local/state/opencode \
  -v "${EDITOR_HOST_PATH}:/usr/bin/${EDITOR_BASENAME}:ro" \
  -v "$(pwd)":/work \
  local/opencode-sandbox \
  ${RUN_ARGS[@]+"${RUN_ARGS[@]}"}

#!/bin/bash

CWD="$(pwd)"

{
  test -d "${HOME}/.config/opencode" \
  && test -d "${HOME}/.cache/opencode" \
  && test -d "${HOME}/.local/state/opencode"
} || {
  echo "ERROR! Please run native opencode at least once."
  exit 1
}

docker run --rm -ti --name "opencode-$(basename "${CWD}")-$(date +%Y%m%d-%H%M%S)" \
  -v "${HOME}/.config/opencode":/home/opencode/.config/opencode:ro \
  -v "${HOME}/.cache/opencode":/home/opencode/.cache/opencode \
  -v "${HOME}/.local/state/opencode":/home/opencode/.local/state/opencode \
  -v "$(pwd)":/work \
  agrrh/opencode-sandbox:latest

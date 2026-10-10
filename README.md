<div align="center">

# 🧊 opencode-sandbox

**A tiny, disposable Docker sandbox for running the [opencode](https://opencode.ai) AI coding agent.**

Keep your agent contained. Point it at a project, let it work, throw the container away.

[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-brightgreen.svg)](http://www.wtfpl.net/)
[![Base Image](https://img.shields.io/badge/base-ubuntu%2024.04-E95420.svg)](https://hub.docker.com/_/ubuntu)
[![opencode](https://img.shields.io/badge/agent-opencode-000000.svg)](https://opencode.ai)

</div>

---

## ✨ Why

`opencode` is powerful — and powerful tools deserve a blast radius. This image gives you:

- 🧱 **Isolation** — the agent only sees the directory you mount, nothing else.
- 🧹 **Disposable** — `--rm` means every run vanishes without a trace.
- 🔋 **Batteries included** — Go, Python, Node 24, git, ripgrep, jq, and friends.
- 🔌 **Persistent config** — your opencode config, cache, and state are mounted so auth and preferences survive.

## 📦 What's inside

| Category | Tools |
| --- | --- |
| **Runtime** | Node.js 24, Python 3, Go |
| **Build** | `make`, `g++`, `unzip`, `rsync` |
| **CLI** | `git`, `curl`, `jq`, `ripgrep`, `dnsutils`, `lsof`, `psmisc`, `procps` |
| **Shell** | `bash`, `man-db`, `less`, `socat`, `bc` |
| **Agent** | [`opencode`](https://opencode.ai) (installed globally via npm) |

## ✅ Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- A host `~/.config/opencode` if you want your existing configuration reused

## 🚀 Quick start

### 1. Build the image

```bash
docker build -t local/opencode-sandbox .
```

### 2. Launch against your project

```bash
./opencode-sandbox.sh
```

That's it. The script runs the sandbox with your **current directory** mounted as `/work`
and starts opencode in auto mode.

## 🛠 Usage

### The launcher script

`opencode-sandbox.sh` is a thin, readable wrapper. It invokes:

```bash
docker run --rm -ti \
  --name "opencode-$(basename "$PWD")-$(date +%Y%m%d-%H%M%S)" \
  -v "$HOME/.config/opencode":/home/opencode/.config/opencode:ro \
  -v "$HOME/.cache/opencode":/home/opencode/.cache/opencode \
  -v "$HOME/.local/state/opencode":/home/opencode/.local/state/opencode \
  -v "$PWD":/work \
  local/opencode-sandbox \
  opencode --auto
```

Run it from any project directory:

```bash
cd ~/projects/my-app
/path/to/opencode-sandbox.sh
```

### Manual invocation

Prefer full control? Skip the script:

```bash
docker run --rm -ti -v "$PWD":/work local/opencode-sandbox
```

## 📁 Mounted volumes

| Host path | Container path | Mode | Purpose |
| --- | --- | --- | --- |
| `$PWD` | `/work` | rw | The project the agent operates on |
| `~/.config/opencode` | `/home/opencode/.config/opencode` | **ro** | Configuration & credentials |
| `~/.cache/opencode` | `/home/opencode/.cache/opencode` | rw | Model / response cache |
| `~/.local/state/opencode` | `/home/opencode/.local/state/opencode` | rw | Session state |

> Config is mounted **read-only** so a runaway agent can't rewrite your credentials.

## 🎛 Customizing

- **Add tools** — append packages to the `apt-get install` block in the [`Dockerfile`](./Dockerfile).
- **Change the entrypoint** — override `CMD`, e.g. `docker run --rm -ti local/opencode-sandbox bash` for a shell.
- **Lock down the network** — pass Docker network flags (`--network none`) when you want a fully offline run.

## 📄 License

Released under the [WTFPL](http://www.wtfpl.net/) — the *Do What The Fuck You Want To Public License*.

```
        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
```

<div align="center">
<sub>Built for people who like their agents on a leash. 🐕🦺</sub>
</div>

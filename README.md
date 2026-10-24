<div align="center">

# 🧊 opencode-sandbox

**A secure, disposable Docker sandbox for running the [opencode](https://opencode.ai) AI coding agent.**

*Keep your agent contained. Point it at a project, let it work, throw the container away.*

[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-brightgreen.svg)](http://www.wtfpl.net/)
[![Base Image](https://img.shields.io/badge/base-Ubuntu%2024.04-E95420.svg)](https://hub.docker.com/_/ubuntu)
[![opencode](https://img.shields.io/badge/agent-opencode-000000.svg)](https://opencode.ai)

</div>

---

## ✨ Features

- 🔒 **Sandboxed Execution** — Run opencode in an isolated container with limited access to your filesystem
- 🧹 **Fully Disposable** — Containers are automatically removed on exit (`--rm`), leaving no traces behind
- 🔋 **Batteries Included** — Comes pre-installed with essential dev tools for most coding workflows
- 💾 **Persistent Configuration** — Your opencode auth, settings, and preferences persist across runs via mounted volumes
- ⚡ **Quick & Easy** — Simple launcher script gets you up and running in seconds
- 🛡️ **Read-Only Config** — Credentials and config are mounted read-only for extra safety

## 📦 What's Included

| Category | Tools |
| --- | --- |
| **Runtimes** | [Node.js 24](https://nodejs.org/), [Python 3](https://www.python.org/), [Go](https://go.dev/) |
| **Build Tools** | `make`, `g++`, `gcc`, `unzip`, `rsync` |
| **Version Control & Utils** | `git`, `curl`, `wget`, `jq` |
| **System Tools** | `dnsutils`, `lsof`, `psmisc`, `procps`, `socat`, `bc` |
| **Shell & Docs** | `bash`, `man-db`, `less`, `ca-certificates` |
| **AI Agent** | [`opencode-ai`](https://opencode.ai) |

## ✅ Prerequisites

Before you begin, ensure you have the following:

- [Docker](https://docs.docker.com/get-docker/) installed and running
- [opencode](https://opencode.ai) run at least once natively to generate config/cache/state directories in `~/.config/opencode/`, `~/.cache/opencode/`, and `~/.local/state/opencode/`
- A project directory you want the agent to work on

## 🚀 Quick Start

### 1. Build the Docker image

```bash
docker build -t local/opencode-sandbox .
```

### 2. Run from your project directory

```bash
cd /path/to/your-project
/path/to/opencode-sandbox/opencode-sandbox.sh
```

The launcher will automatically mount your current directory to `/work`, load your existing opencode configuration, and start opencode in auto mode.

## 🛠️ Usage

### Using the launcher script (Recommended)

The included `opencode-sandbox.sh` script handles all the volume mounts and configuration for you. It will:

1. Check for required opencode config directories on your host
2. Create a uniquely named container for your session
3. Mount your project, config (read-only), cache, and state
4. Launch opencode in auto mode

```bash
./opencode-sandbox.sh
```

> **Note:** If you see `ERROR! Please run native opencode at least once.`, run `opencode` on your host machine first to initialize the necessary directories.

### Manual invocation

For more control over the container, you can run Docker directly:

```bash
docker run --rm -ti \
  -v "$PWD":/work \
  -v "$HOME/.config/opencode":/home/opencode/.config/opencode:ro \
  -v "$HOME/.cache/opencode":/home/opencode/.cache/opencode \
  -v "$HOME/.local/state/opencode":/home/opencode/.local/state/opencode \
  local/opencode-sandbox
```

By default, the container runs `opencode --auto`. You can override the command entirely:

```bash
# Start an interactive shell
docker run --rm -ti -v "$PWD":/work local/opencode-sandbox bash

# Run opencode with custom flags
docker run --rm -ti -v "$PWD":/work local/opencode-sandbox opencode --help
```

## 📁 Volume Mounts

| Host Path | Container Path | Mode | Purpose |
| --- | --- | --- | --- |
| `$PWD` (your project) | `/work` | `rw` | Project files the agent can read and modify |
| `~/.config/opencode` | `/home/opencode/.config/opencode` | `ro` | Auth tokens, API keys, and configuration |
| `~/.cache/opencode` | `/home/opencode/.cache/opencode` | `rw` | Response and model caches for faster runs |
| `~/.local/state/opencode` | `/home/opencode/.local/state/opencode` | `rw` | Session history and agent state |

> **Security Note:** The configuration directory is mounted read-only to prevent the agent from accidentally modifying your credentials or config files.

## 🎛️ Customization

### Add more tools

To install additional packages, edit the `apt-get install` section in the [Dockerfile](./Dockerfile):

```dockerfile
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    your-package-here \
    another-package \
  ...
```

Rebuild the image after making changes: `docker build -t local/opencode-sandbox .`

### Use a different base image or opencode version

Modify the `FROM` line or `OPENCODE_VERSION` environment variable in the [Dockerfile](./Dockerfile):

```dockerfile
ENV OPENCODE_VERSION=1.20.0  # Update to your desired version
```

### Run offline or with restricted network

For maximum isolation, run with no network access:

```bash
docker run --rm -ti --network none -v "$PWD":/work local/opencode-sandbox
```

### Use the pre-built image

If available, you can pull from Docker Hub instead of building locally:

```bash
docker pull agrrh/opencode-sandbox:latest
```

Update `opencode-sandbox.sh` to use `agrrh/opencode-sandbox:latest` if needed.

## 🔍 Troubleshooting

| Issue | Solution |
| --- | --- |
| `ERROR! Please run native opencode at least once.` | Run `opencode` on your host machine to create the required config directories. |
| Permission denied errors | Ensure your user owns the project files. The container runs as UID 1000 (`opencode`). |
| Missing tools in container | Add them to the Dockerfile and rebuild the image. |
| Config not loading | Check that `~/.config/opencode` exists and contains valid configuration. |

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to add more tools, improve the setup, or enhance security.

## 📄 License

Released under the [WTFPL](http://www.wtfpl.net/) — *Do What The Fuck You Want To Public License*.

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

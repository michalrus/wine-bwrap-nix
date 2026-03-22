# wine-bwrap-nix

Sandboxed Wine wrappers for Linux using [Bubblewrap](https://github.com/containers/bubblewrap) and [Nix](https://nixos.org/).

Run Windows applications via Wine inside a tightly locked-down sandbox with namespace isolation, a minimal filesystem view, and optional network access.

## Why?

Running Wine on Linux exposes your entire home directory, filesystem, and network to potentially untrusted Windows executables. wine-bwrap-nix wraps Wine invocations inside Bubblewrap containers that:

- **Isolate the filesystem** – the Windows app only sees the Nix store (read-only), the `WINEPREFIX` directory, and a dedicated `sandbox-home` – not your real home.
- **Isolate the network** – by default, the sandbox has no network access (loopback only), with an opt-in networked variant.
- **Isolate namespaces** – uses `--unshare-all`, `--new-session`, `--die-with-parent`, and `--clearenv` for defense-in-depth (PID, mount, user, network, IPC, UTS).
- **Bundle Wine addons** – automatically downloads and bind-mounts the correct versions of Wine Mono and Wine Gecko, matched to the Wine version in nixpkgs.

## Provided Commands

| Command                 | Network | Description                                                                                                       |
| ----------------------- | ------- | ----------------------------------------------------------------------------------------------------------------- |
| `wine-bwrap`            | No      | Primary sandbox for running `.exe` files without network access.                                                  |
| `wine-bwrap-networked`  | Yes     | For apps that require internet access.                                                                            |
| `wine-bwrap-winetricks` | Yes     | Runs [winetricks](https://github.com/Winetricks/winetricks) inside the sandbox for installing Windows components. |

## Installation

### Nix Flakes

```bash
# Run directly
nix run github:michalrus/wine-bwrap-nix -- <exe>

# Or build it
nix build github:michalrus/wine-bwrap-nix

# Or add as a flake input
{
  inputs.wine-bwrap-nix.url = "github:michalrus/wine-bwrap-nix";
}
```

### Non-Flake Nix

```bash
nix-build default.nix
```

## Usage

Set `WINEPREFIX` to a directory for your Wine bottle, then run one of the wrapper commands:

```bash
export WINEPREFIX=~/my-wine-prefix

# Run a Windows .exe in an isolated sandbox (no network)
wine-bwrap ./setup.exe

# Run with network access
wine-bwrap-networked ./online-app.exe

# Run winetricks to install Windows components
wine-bwrap-winetricks vcrun2022
```

A `sandbox-home` subdirectory is created inside the `WINEPREFIX` to serve as `$HOME` within the sandbox.

**Important:** The Windows executable you want to run must be located within (or below) the `WINEPREFIX` directory, as that is the only writable path mounted into the sandbox. Files outside of it will not be visible to Wine.

## Environment Variables

| Variable                               | Required | Description                             |
| -------------------------------------- | -------- | --------------------------------------- |
| `WINEPREFIX`                           | Yes      | Path to the Wine prefix directory.      |
| `DISPLAY`                              | No       | Enables X11 passthrough when set.       |
| `WINEARCH`                             | No       | Wine architecture (`win32` or `win64`). |
| `WINEDEBUG`                            | No       | Wine debug channels (e.g. `-all`).      |
| `WINEDLLOVERRIDES`                     | No       | DLL override settings.                  |
| `WINEESYNC` / `WINEFSYNC` / `WINESYNC` | No       | Synchronization primitive toggles.      |
| `WINELOADER` / `WINESERVER`            | No       | Custom Wine loader/server paths.        |

## Requirements

- **Linux** (`x86_64-linux` or `aarch64-linux`)
- **Nix** (flakes support recommended)
- Unprivileged user namespaces must be enabled (no root/setuid required)

## License

[Apache License 2.0](LICENSE)

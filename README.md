# Sysmon

CPU, RAM, and GPU usage/temperature chips for the Omarchy bar — with sparklines,
alert colors, a per-metric detail popup, and a settings panel.

**ID:** `local.sysmon`

## Install

Omarchy’s plugin installer clones the repo and, when you pass `--enable`, asks
which bar section to use (left / center / right). That prompt comes from
`omarchy plugin add` itself — the plugin only needs a `barWidget` entry and an
optional `defaultSection` in `manifest.json`.

```sh
omarchy plugin add https://github.com/<you>/sysmon-plugin.git --enable
```

Or from a local checkout:

```sh
# copy/clone into ~/.config/omarchy/plugins/local.sysmon
omarchy plugin enable local.sysmon --section right
```

## Usage

| Input | Action |
|-------|--------|
| Left-click a chip | Detail popup for that metric (per-core for CPU/temp) |
| Right-click any chip | Settings (alert thresholds + graph toggles) |

Samples refresh about once per second via `scripts/probe` (Python 3, plus
`nvidia-smi` when present).

## Settings

Persisted in `shell.json` on the bar entry (also editable via Omarchy’s plugin
schema):

- Alert thresholds: CPU %, CPU °C, RAM %, GPU %, GPU °C
- Graph on/off per metric

## Remove

```sh
omarchy plugin remove local.sysmon
```

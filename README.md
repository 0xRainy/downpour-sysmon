# Downpour Sysmon

CPU, RAM, and GPU usage/temperature chips for the [Omarchy](https://omarchy.org) bar — sparklines, alert colors, detail popups, and a settings panel.

**ID:** `0xrainy.sysmon`  
**Host theme:** named after `downpour`

## Install

```sh
omarchy plugin add https://github.com/0xRainy/downpour-sysmon.git --enable
```

Omarchy will ask which bar section to use (left / center / right).

## Usage

| Input | Action |
|-------|--------|
| Left-click a chip | Detail popup (per-core for CPU/temp; combined GPU view) |
| Right-click any chip | Settings (visibility, alert thresholds, graphs) |

At least one chip must stay visible so settings remain reachable.

## Remove

```sh
omarchy plugin remove 0xrainy.sysmon
```

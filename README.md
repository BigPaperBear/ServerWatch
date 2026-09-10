# ServerWatch

A lightweight World of Warcraft addon that warns you when the server stops responding.

Originally created by **shunrai4714**.

## What it does

ServerWatch keeps an eye on your connection to the game server. If the server goes
unresponsive, a large on-screen warning appears along with a raid warning sound, so
you know immediately instead of finding out the hard way. Once the server responds
again, the warning clears automatically and you'll get a confirmation message.

## Slash Commands

- `/serverwatch status` or `/swatch status` — Shows whether the monitor is active,
  whether it currently thinks the connection is down, and how long ago the server
  last responded.
- `/serverwatch test` or `/swatch test` — Manually triggers (or clears) the warning,
  useful for checking that the addon is working.

## Installation

1. Copy the `ServerWatch` folder into your `Interface\AddOns` directory.
2. Make sure the addon is enabled on the character select screen's AddOns list.

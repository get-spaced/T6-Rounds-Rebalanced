# T6 Rounds Rebalanced

**A round-scaling and high-round quality-of-life mod for Call of Duty: Black Ops II Zombies on Plutonium T6.**

T6 Rounds Rebalanced aims to make long Zombies matches more manageable without removing the challenge of the early rounds. Zombie counts scale up normally at first, then stop at a predictable player-based limit. Zombie health also stops increasing after round 30, and the mod includes a change intended to let rounds progress beyond the original round-255 cap.

## Features

### Player-Scaled Zombie Limit

- Preserves the normal **early-round increase** instead of spawning the maximum number of zombies immediately.
- Caps the **total zombies per regular round** at **24 × the number of connected players**.
- Supports player-count scaling for **1–8 players**, where supported by the server.
- Does **not** intentionally change how many zombies can be alive simultaneously or their spawn timing; the cap applies to the total round count.

| Players | Maximum Zombies per Round |
|---|---:|
| 1 | 24 |
| 2 | 48 |
| 3 | 72 |
| 4 | 96 |
| 5 | 120 |
| 6 | 144 |
| 7 | 168 |
| 8 | 192 |

### Zombie Health Cap

- Normal zombie health progression is retained through round 30.
- From round 31 onward, ordinary zombies use the round-30 health value.
- Special enemies and bosses with separate health calculations may not follow this cap.

### Extended Round Progression

- Removes the original round-255 clamp from the custom round handler.
- Designed to support progression toward round 999,999.
- Actual maximum playable rounds may still be limited by the game engine, HUD, statistics, or map scripts.

## Example Progression

| Rounds | Zombie Count | Zombie Health |
|---|---|---|
| Early rounds | Normal early-round progression | Normal scaling |
| 30 | Up to 24 per player | Round-30 health |
| 31–255 | Up to 24 per player | Capped at round 30 |
| 256+ | Up to 24 per player | Capped at round 30 |

## Requirements

- **Game:** Call of Duty: Black Ops II Zombies
- **Platform:** Plutonium T6
- **Language:** GSC

## Installation

1. Download the mod's `.gsc` file.
2. Open your Plutonium T6 Zombies scripts folder:

   `%localappdata%\Plutonium\storage\t6\scripts\zm`

3. Place the `.gsc` file inside the folder.
4. Launch Plutonium T6 Zombies and start a new match.

For alternative installation methods, see the [official Plutonium guide](https://plutonium.pw/docs/modding/loading-mods/).

## Configuration

The default gameplay settings are:

| Setting | Value |
|---|---|
| Maximum zombies per player | `24` |
| Zombie health cap round | `30` |
| Intended extended-round target | `999999` |

These values are currently defined in the GSC source and can be changed manually.

## Compatibility

Designed for regular Plutonium T6 Zombies rounds. Special enemy rounds, custom maps, and other modifications that replace round or zombie-health functions may behave differently.

Extended progression to round 999,999 is a design target and is not guaranteed to be supported by every game-engine system.

## Disclaimer

This is an unofficial community modification and is not affiliated with or endorsed by Activision, Treyarch, or the Plutonium Project.

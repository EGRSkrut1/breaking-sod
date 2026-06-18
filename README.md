# Breaking Sod

**Breaking Sod** is an economic farming simulation game with underground exploration, processing chains, and dynamic trading. Built with Godot 4.

> Break ground, grow crops, process materials, and sell to customers — all while managing resources, energy, and sleep.

---

## 🎮 Features

### 🌾 Farming
- Plant, water, and harvest 3 plant types: **Green Weed**, **Purple Haze**, **White Widow**
- Each plant has unique growth time, water requirements, and sell price
- Growth stages with visual feedback and withering mechanics

### 🏭 Processing Chain
- **Graver** → Chop raw plants (+50% value)
- **Dryer** → Dry chopped plants (+100% value)
- **Wrapper** → Pack dried plants (+200% value)

### 💰 Economy
- Dual currency: **Cash** (physical) and **Card** (digital)
- **ATM** for currency conversion
- **PC / Darknet** for seed purchases and equipment upgrades
- Dynamic customer trading with price negotiation and irritation system

### ⛏️ Basement
- Dig through dirt and stone to expand your underground area
- Collect rare items: Tin Can, Old Coin, Crystal
- Build equipment underground (PC, Bed, Processing units)

### 💤 Player Stats
- **Energy** — consumed by digging, restored by sleeping
- **Sleep** - depletes over time (maximum 48 game hours), when depleted, you lose consciousness, the more you don't sleep, the more you will sleep, minimum 4 hours, maximum 16 hours
- **Suspicion** — increases with illegal sales, attracts police attention

### 💾 Save System
- Separate save files for **Forest** and **Basement** maps
- Crops, buildings, inventory, and player position all persist

### 🖥️ Developer Console
- Press **`** (tilde) to open
- Commands: `add_money`, `give_item`, `unlock_seed`, `time`, `day`, and more
- History navigation with arrow keys

---

## 🕹️ Controls

| Action | Input |
|--------|-------|
| Move | WASD / Arrow Keys |
| Interact (open building / talk to customer) | E |
| Harvest / Dig / Build | Left Mouse Click |
| Open Build Menu | Click Build button in UI |
| Cancel / Close menus | ESC |
| Open Console | ` (tilde) |
| Toggle Irrigation system| F |

---

## 🏗️ Buildings

| Building | Function |
|----------|----------|
| Crop | Garden bed for planting seeds |
| Well | Water source (refills over time) |
| PC | Access darknet market for seeds/equipment |
| ATM | Convert cash ↔ card money |
| Basement | Enter underground mining area |
| Bed | Restore energy and sleep |
| Graver | Process raw plants → Lvl1 |
| Dryer | Dry Lvl1 plants → Lvl2 |
| Wrapper | Pack Lvl2 plants → Lvl3 |

---

## 🧪 Plant Levels

| Level | Green | Purple | White |
|-------|-------|--------|-------|
| Raw | $15 | $30 | $50 |
| Lvl 1 (Chopped) | $22 | $45 | $75 |
| Lvl 2 (Dried) | $30 | $60 | $100 |
| Lvl 3 (Wrapped) | $45 | $90 | $150 |

---

## 🛠️ Tech Stack

- **Engine**: Godot 4.x
- **Language**: GDScript
- **Save System**: JSON (user://savegame.json)
- **UI**: Godot native Control nodes

---

## 🚀 Getting Started

### Prerequisites
- Godot 4.2 or higher
- Windows / Linux / macOS

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/EGRSkrut1/breaking-sod.git



## License
```
MIT License

Copyright (c) 2026 EGRSKRUT

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
---

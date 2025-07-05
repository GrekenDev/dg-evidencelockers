# dg-evidencelockers

**dg-evidencelockers** is a FiveM evidence locker system designed for police departments using **qbx_core**, **ox_inventory**, **bb_inventory**, **ox_lib**, **oxmysql**, and either **ox_target** or **sleepless_interact**. It allows officers to securely create, access, manage, clear, and delete evidence stashes tied to individuals or cases.

## 🚀 Features

- 📁 Create evidence lockers with any custom name (e.g. suspect name).
- 🔍 Search for an existing locker and access stored items.
- 📜 View all lockers in a specific station and open them.
- 🗑️ Clear lockers (delete contents) or permanently delete lockers.
- ⚖️ Grade-based restrictions for clearing and deleting lockers (`clearRank` / `deleteRank`).
- 👁️ Target system support for [ox_target](https://overextended.dev/ox_target) or [sleepless_interact](https://github.com/Sleepless-Development/sleepless_interact).
- 🎨 Switchable UI: supports `ox_lib` or `Lation UI` for all menus, alerts, and inputs. --- https://lationscripts.com/product/modern-ui
- 🔔 Notifier support: `ox_lib`, `okokNotify`, or `Lation UI` notifications.
- 📦 Fully supports both `ox_inventory` and `bb_inventory`.
- 🧹 Automatic cleanup from `bb_containers` if using `bb_inventory`.
- 🧠 Optimized resmon, dynamic zone spawning only when players are nearby.
- 🌐 Localized out of the box: English & Swedish included.
- 🧩 Version checker included (GitHub integration).

---

## ⚙️ Configuration

Here is an example `config.lua`:

```lua
Config = {}

Config.Interact = "sleepless" -- 'ox_target' or 'sleepless'
Config.Notify = "lation" -- 'ox', 'okok', or 'lation'
Config.NotifyTitle = "Evidence Locker"
Config.NotifyIcon = "fa-solid fa-archive"
Config.NotifyPosition = "center-right"
Config.NotifyDuration = 5000 -- in ms

Config.UseLationUi = true -- Enables Lation UI menus/dialogs
Config.UseBbInv = true -- Enables bb_inventory deletion support

Config.EvidenceLockers = {
  ["VinewoodPoliceDep"] = {
    coords = vector3(605.60, 7.80, 75.04),
    jobs = { "police", "fib" },
    clearRank = 0,
    deleteRank = 0,
    stashWeight = 500000,
    stashSlots = 20,
  },
  ["Mrpd"] = {
    coords = vector3(604.75, 5.55, 75.04),
    jobs = { "ambulance", "fib" },
    clearRank = 0,
    deleteRank = 0,
    stashWeight = 500000,
    stashSlots = 20,
  }
}

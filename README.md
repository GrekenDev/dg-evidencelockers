# dg-evidencelockers

**dg-evidencelockers** is a FiveM evidence locker system designed for police forces using **qbx_core, ox_inventory, ox_lib, ox_target/sleepless_interact, and oxmysql**. It allows officers to create, search, and manage evidence lockers for arrested individuals.

## 🚀 Features

- 📁 Create evidence lockers with a person's name.
- 🔍 Search for an existing locker and access stored items.
- 📜 View all created lockers and select which one to open.
- 👁️ Target with either ox_target or sleepless_interact https://github.com/Sleepless-Development/sleepless_interact // You can also add or edit to your personal target script!
- 🗑️ Delete created lockers or just clear them if you want to keep the stash itself
- 🎯 Secure system with job-based restrictions.
- 🔥 Optimized **ox_target** & **sleepless_intercat** zone handling for better performance.
- 🌍 Multi-language support (English & Swedish included).

## 📂 Installation

1. Download or clone this repository into your `resources` folder.
2. Ensure all dependencies are installed:
3. Run the SQL

   - [ox_inventory](https://overextended.dev/ox_inventory/)
   - [ox_lib](https://overextended.dev/ox_lib/)
   - [ox_target](https://overextended.dev/ox_target/) ---Optional
   - [qbx_core](https://docs.qbox.re/)
   - [oxmysql](https://overextended.dev/oxmysql/)
   - [sleepless](https://github.com/Sleepless-Development/sleepless_interact) --- Optional

4. Add the resource to your **server.cfg**:
   ```ini
   ensure dg-evidencelockers
   ```

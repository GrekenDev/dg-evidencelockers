# dg-evidencelockers

**dg-evidencelockers** is a FiveM evidence locker system designed for police forces using **qbx_core, ox_inventory, ox_lib, ox_target, and oxmysql**. It allows officers to create, search, and manage evidence lockers for arrested individuals.

## 🚀 Features

- 📁 Create evidence lockers with a person's name.
- 🔍 Search for an existing locker and access stored items.
- 📜 View all created lockers and select which one to open.
- 🎯 Secure system with job-based restrictions.
- 🔥 Optimized **ox_target** zone handling for better performance.
- 🌍 Multi-language support (English & Swedish included).

## 📂 Installation

1. Download or clone this repository into your `resources` folder.
2. Ensure all dependencies are installed:
3. Run the SQL

   - [ox_inventory](https://overextended.dev/ox_inventory/)
   - [ox_lib](https://overextended.dev/ox_lib/)
   - [ox_target](https://overextended.dev/ox_target/)
   - [qbx_core](https://docs.qbox.re/)
   - [oxmysql](https://overextended.dev/oxmysql/)

4. Add the resource to your **server.cfg**:
   ```ini
   ensure dg-evidencelockers
   ```

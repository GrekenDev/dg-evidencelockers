Config = {}

Config.Interact = "sleepless" -- ox_target or sleepless
Config.Notify = "lation" -- ox for ox_lib, okok for okok_notify, 'lation' for Lation UI, 
Config.NotifyTitle = "Evidence Locker" -- Title for notifications
Config.NotifyIcon = "fa-solid fa-archive" -- -- notify icon https://fontawesome.com/search?ic=free
Config.NotifyPosition = "center-right" -- top, bottom, left, right
Config.NotifyDuration = 5000 -- in milliseconds

Config.UseLationUi = true -- Use Lation UI for evidence locker, this will override ox_libs ui
Config.UseBbInv = true -- If you use bb_inventory, set this to true. Otherwise you wont be able to delete lockers

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
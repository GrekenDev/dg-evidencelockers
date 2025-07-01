Config = {}

Config.Interact = "sleepless" -- ox_target or sleepless
Config.Notify = "ox" -- ox for ox_lib, okok for okok_notify,
Config.NotifyTitle = "Evidence Locker" -- Title for notifications
Config.NotifyIcon = "fa-solid fa-archive" -- -- notify icon https://fontawesome.com/search?ic=free
Config.NotifyPosition = "center-right" -- top, bottom, left, right
Config.NotifyDuration = 5000 -- in milliseconds


Config.EvidenceLockers = {
  ["VinewoodPoliceDep"] = {
    coords = vector3(605.60, 7.80, 75.04),
    jobs = { "police", "fib" },
    clearRank = 2,
    deleteRank = 4,
    stashWeight = 500000,
    stashSlots = 20,
  },
  ["Mrpd"] = {
    coords = vector3(604.75, 5.55, 75.04),
    jobs = { "ambulance", "fib" },
    clearRank = 2,
    deleteRank = 4,
    stashWeight = 500000,
    stashSlots = 20,
  }
}
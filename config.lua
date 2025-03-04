Config = {}

Config.StashLocation = vector3(605.60, 7.80, 75.04) -- Platsen där poliserna kan hantera bevisförråd
Config.StashWeight = 500000                         -- Maxvikt i kg som varje fack kan ha
Config.StashSlots = 20                              -- Antal slots i varje förråd

Config.AllowedJobs = {                              -- Vilka jobb som har tillgång till att använda systemet
  ["police"] = true,
  ["detective"] = true
}

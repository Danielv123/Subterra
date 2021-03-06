data:extend({
  {
    type = "recipe",
    name = "subterra-belt-down",
    energy_required = 1,
    ingredients =
    {
      {"underground-belt", 2},
      {"transport-belt", 5},
      {"iron-gear-wheel", 10}
    },
    results = {{"subterra-belt-down", 1}},
    requester_paste_multiplier = 4
  },
  {
    type = "recipe",
    name = "subterra-belt-up",
    energy_required = 1,
    ingredients =
    {
      {"underground-belt", 2},
      {"transport-belt", 5},
      {"iron-gear-wheel", 10}
    },
    results = {{"subterra-belt-up", 1}},
    requester_paste_multiplier = 4
  },
  {
    type = "recipe",
    name = "subterra-belt-down-ex",
    ingredients =
    {
      {"subterra-belt-up", 1}
    },
    results = {{"subterra-belt-down", 1}},
    requester_paste_multiplier = 4
  },
  {
    type = "recipe",
    name = "subterra-belt-up-ex",
    ingredients =
    {
      {"subterra-belt-down", 1}
    },
    results = {{"subterra-belt-up", 1}},
    requester_paste_multiplier = 4
  }
})
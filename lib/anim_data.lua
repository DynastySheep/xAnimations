return {
    sleep = {
        title = "Sleepy time zzz",
        scenario = "WORLD_HUMAN_BUM_SLUMPED"
    },
    spy = {
        title = "Spying on your neighbours",
        scenario = "WORLD_HUMAN_BINOCULARS"
    },
    smoke = {
        title = "Smoking kills",
        scenario = "WORLD_HUMAN_SMOKING"
    },
    clean = {
        title = "",
        scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER"
    },
    test = {
        title = "Testing",
        dictionary = "missheist_jewel",
        name = "smash_case",
        duration = -1,
        flag = 1
    },
    hug = {
        title = "Testing",
        dictionary = "mp_ped_interaction",
        name = "kisses_guy_b",
        duration = -1,
        flag = 4
    },
    burger = {
        title = "Testing",
        dictionary = "mp_player_inteat@burger",
        name = "mp_player_int_eat_burger",
        prop = "prop_cs_burger_01",
        bone = 18905,
        placement = {0.13,0.05,0.02,-50.0,16.0,60.0},
        duration = -1,
        flag = 48
    }
}

--[[
Odd number : loop infinitely  
Even number : Freeze at last frame  
Multiple of 4: Freeze at last frame but controllable  
01 to 15 > Full body  
10 to 31 > Upper body  
32 to 47 > Full body > Controllable  
48 to 63 > Upper body > Controllable  
]]
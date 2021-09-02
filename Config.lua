Config = {
    Locker = {X= -1404.80, Y= -604.74, Z= 30.32}, -- Position of the locker
    Uniforms = { -- Work uniforms (Make {} for none)
        Male= {
            tshirt_1 = 0,  tshirt_2 = 3,
			torso_1 = 269,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 0,
			pants_1 = 26,   pants_2 = 8,
			shoes_1 = 1,   shoes_2 = 2,
            helmet_1 = 15,  helmet_2 = 2,
			ears_1 = -1,     ears_2 = 0
        },
        FeMale= {
             tshirt_1 = 16,  tshirt_2 = 1,
			torso_1 = 278,   torso_2 = 9,
			decals_1 = 0,   decals_2 = 0,
			arms = 4,
			pants_1 = 27,   pants_2 = 0,
			shoes_1 = 1,   shoes_2 = 11,
            helmet_1 = 15,  helmet_2 = 6,
			ears_1 = -1,     ears_2 = 0
        }
    },

    Garage = {X= -1392.99, Y= -588.18, Z= 30.26}, -- Position of the garage
    VehicleSpawn = {X= -1393.99, Y= -581.94, Z= 30.16, Heading= 302.61}, -- Position where the vehicle will spawn
    VehicleDelete = {X= -1398.92, Y= -584.7, Z= 30.32}, -- Position where the vehicle can despawn

    Vehicles = { -- All vehicles that can be spawned from the menu
        {Name= "Cyclone", SpawnName= "cyclone"},
        {Name= "FMJ", SpawnName= "fmj"}
    },
    LicensePlate = "Club-DJ", -- Make "" for random text

    BlipName = "Nightclub", -- Name of the marker on the map
    JobBlipName = "Nightclub Job", -- Name of the marker on the map

    MoneyType = true, -- True= Cash | False= Bank
    MoneyAmount = 2500, -- Money you get for completing 1 job

    Translation = "EN", -- Translation to use

    Jobs = { -- Positions of available jobs
        {X= -561.09, Y= 281.80, Z= 85.68},
		{X= 334.35, Y= -911.93, Z= 29.26},
        {X= -1381.39, Y= -616.44, Z= 31.50},
		 {X= -805.44, Y= -592.72, Z= 30.32}
    },

    TranslationList = { -- List of all translation which you car choose
        ["EN"] = {
            ["LOCKER_HELP"] = "Press ~INPUT_CONTEXT~ to open the locker!",
            ["LOCKER_MENU"] = "Locker Menu",
            ["WORK_CLOTHES"] = "Work Clothes",
            ["NORMAL_CLOTHES"] = "Normal Clothes",

            ["GARAGE_HELP"] = "Press ~INPUT_CONTEXT~ to open the garage!",
            ["GARAGE_MENU"] = "Garage Menu",
            ["GARAGE_PROBLEM"] = "~r~ Something went wrong while spawning the vehicle. (Stopped to prevent crash!)",
            
            ["DELETE_HELP"] = "Press ~INPUT_CONTEXT~ to delete your vehicle!",

            ["MENU_HELP"] = "Press ~g~PgUp ~w~to open your menu!",
            ["MENU_MENU"] = "Menu",
            ["MENU_NEW"] = "Get new gig",
            ["MENU_CREATED"] = "~g~ You got another Gig!",
            ["MENU_CANCEL"] = "Cancel current gig",
            ["MENU_CANCELED"] = "~g~ Succesfully canceled your gig!",
            ["MENU_ALREADY"] = "~r~ You are already doing a gig! You first need to cancel it.",
            ["MENU_NONE"] = "~r~ You have no active gigs!",

            ["JOB_HELP"] = "Press ~INPUT_CONTEXT~ to take a look!",
            ["JOB_DONE"] = "~g~ Finished your set. You have earned ~b~$2500,~g~ for it!"
        },
        ["NL"] = {
            ["LOCKER_HELP"] = "Druk op ~INPUT_CONTEXT~ om de kleding kast te openen!",
            ["LOCKER_MENU"] = "Kleding Menu",
            ["WORK_CLOTHES"] = "Werk Kleding",
            ["NORMAL_CLOTHES"] = "Normale Kleding",

            ["GARAGE_HELP"] = "Druk op ~INPUT_CONTEXT~ om de garage te openen!",
            ["GARAGE_MENU"] = "Garage Menu",
            ["GARAGE_PROBLEM"] = "~r~ Er is iets fout gegaan tijdens het spawnen van het voertuig. (Gestopt om een crash te voorkomen!)",
            
            ["DELETE_HELP"] = "Druk op ~INPUT_CONTEXT~ om je voertuig je verwijderen!",

            ["MENU_HELP"] = "Druk op ~INPUT_SELECT_CHARACTER_FRANKLIN~ om je menu te openen!",
            ["MENU_MENU"] = "Menu",
            ["MENU_NEW"] = "Nieuwe opdracht",
            ["MENU_CREATED"] = "~g~ Succesvol een nieuw opdracht gemaakt!",
            ["MENU_CANCEL"] = "Beëindig huidige opdracht",
            ["MENU_CANCELED"] = "~g~ Opdracht succesvol beëindigd!",
            ["MENU_ALREADY"] = "~r~ U bent als bezig met een opdracht! U moet deze eerst beëindigen.",
            ["MENU_NONE"] = "~r~ U heeft geen huidige opdracht!",

            ["JOB_HELP"] = "Druk op ~INPUT_CONTEXT~ om een kijkje te nemen!",
            ["JOB_DONE"] = "~g~ Het probleem is succesvol op gelost. Je hebt er ~b~€100,-~g~ voor gekregen!"
        }
    }
}
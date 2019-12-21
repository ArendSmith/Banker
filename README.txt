Banker DarkRP Addon by Ren
----------------------------------------

This mod creates an entity called 'Banker'. This NPC will prompt a UI which allows players to either withdraw or
deposit money. This mod is especially useful for hardcore realism RP where money is lost on death.

----------------------------------------

Please note that this addon requires the following job classes or classes with similar Team Names.
This code needs to be placed in: C:\garrysmod\garrysmod\addons\darkrpmodification\lua\darkrp_customthings\jobs.lua

//Code//

TEAM_BANKSECURITY = DarkRP.createJob("Bank Security", {
    color = Color(75, 75, 75, 255),
    model = {
        "models/player/Group03/Female_01.mdl",
        "models/player/Group03/Female_02.mdl",
        "models/player/Group03/Female_03.mdl",
        "models/player/Group03/Female_04.mdl",
        "models/player/Group03/Female_06.mdl",
        "models/player/group03/male_01.mdl",
        "models/player/Group03/Male_02.mdl",
        "models/player/Group03/male_03.mdl",
        "models/player/Group03/Male_04.mdl",
        "models/player/Group03/Male_05.mdl",
        "models/player/Group03/Male_06.mdl",
        "models/player/Group03/Male_07.mdl",
        "models/player/Group03/Male_08.mdl",
        "models/player/Group03/Male_09.mdl"},
    description = [[It is your job to defend bank tellers. Robbers will attempt to rob banks at gun point, you will receive a bonus for stopping them.]],
    weapons = { "weapon_p2282" },
    command = "banksecurity",
    max = 3,
    salary = GAMEMODE.Config.normalsalary,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Private Security",
})

TEAM_THIEF = DarkRP.createJob("Thief", {
    color = Color(25, 198, 198, 255),
    model = {"models/player/arctic.mdl"},
    description = [[This job can raid bases (must advert raid). Thief's also have the ability to rob a bank. When speaking to a bank teller, you will see Thief menu for robbing a bank.]],
    weapons = { "lockpick" },
    command = "thief",
    max = 3,
    salary = GAMEMODE.Config.normalsalary,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Criminals",
})

//Code End//
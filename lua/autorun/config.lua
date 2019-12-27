// CONFIG FILE FOR BANKER //
-- Changing settings in here will effect gameplay, failure to follow these instructions can break the add-on.
-- Make sure to read the ReadMe file before making changes in here.

// Bank UI Title //
-- Changing this variable will change the 'Bank of *Server name here*' at the top of the Banker UI.
CONFIG_SERVER_NAME = "Test Server"

// Banker Model //
-- If you want to use a different model or a custom model, change it here.

CONFIG_BANKER_MODEL = "models/player/gman_high.mdl"

// Robbery Rewards //
-- Change these variables to adjust the rewarded amount of money for when a
-- Thief or Bank Security Guard claims the money bag. We recommend Rewarding
-- Security Guard with 1/4 of the Thieves' reward. Balance this by giving Bank
-- Security a high salary and Thieves a low salary.

-- WARNING: Use a 32-bit number and it will reflect in dollars in-game.

CONFIG_MONEY_BAG_THIEF_REWARD = 1000
CONFIG_MONEY_BAG_SECURITY_REWARD = 250

// Money Bag Timer //
-- This variable controls how long the timer for the Money Bag from when it is
-- stolen to when it can be opened.

-- WARNING: Use a 32-bit number and it will reflect in seconds in-game.

CONFIG_MONEY_BAG_TIMER = 30

// Robbery Cooldown //
-- This variable controls the cooldown between robberies.
-- WARNING: Use a 32-bit number and it will reflect in seconds in-game.

CONFIG_ROBBERY_COOLDOWN = 10

// Max amount of money that can be stored in the bank //
-- Title explains itself
-- WARNING: THIS HAS TO BE A 32-BIT NUMBER, THE HIGHEST IT CAN GO IS 2147483647
-- Any higher value will break the add-on on launch of the server.

CONFIG_BANK_MAX_LIMIT = 2000000000

// List of all Guns on sever a Thief can use to rob the bank //
-- You can add any weapon name into this list and that weapon will pass the
-- check when a thief talks to a banker, allowing for the 'Rob Bank' button
-- to appear on the UI. You can use any item ID here and can usually find them
-- in their SEWP file.

CONFIG_GUN_CHECK_LIST = { "weapon_ak472", "weapon_deagle2", "weapon_fiveseven2",
"weapon_glock2", "weapon_m42", "weapon_mac102", "weapon_mp52", "weapon_p2282",
"weapon_pumpshotgun2"
}

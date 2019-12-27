AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include("cl_init.lua")

util.AddNetworkString("BANKER_REQUEST_INTERFACE")
util.AddNetworkString( "BANK_WITHDRAW_REQUEST" )
util.AddNetworkString( "BANK_DEPOSIT_REQUEST" )
util.AddNetworkString( "BANK_NOT_ENOUGH_FUNDS_ERROR" )
util.AddNetworkString( "BANK_FULL_ERROR_ERROR" )
util.AddNetworkString( "BANK_DEPOSIT_CONFIRMED_MESSAGE" )
util.AddNetworkString( "BANK_WITHDRAW_CONFIRMED_MESSAGE" )
util.AddNetworkString( "BANKER_REQUEST_THIEF_INTERFACE" )
util.AddNetworkString( "BANKER_SEND_SILENT_ALARM" )
util.AddNetworkString( "BANKER_REQUEST_SILENT_ALARM_PLAY" )
util.AddNetworkString( "BANKER_ROBBERY_ON_COOLDOWN_WARNING" )
IsOnCoolDown = false

function ENT:Initialize()
  self:SetModel(CONFIG_BANKER_MODEL)
  self:SetHullType(HULL_HUMAN)
  self:SetHullSizeNormal()
  self:SetNPCState(NPC_STATE_SCRIPT)
  self:SetSolid(SOLID_BBOX)
  self:CapabilitiesAdd(CAP_ANIMATEDFACE)
  self:SetUseType(SIMPLE_USE)
  self:DropToFloor()

end

// Function handles user interaction of the entity.
-- Calls new_bank_account() which will decide if the user needs an account
-- initialized in the Sqlite database. Then send a request to the client
-- to display the GUI.
function ENT:AcceptInput(name, activator, caller)

  new_bank_account(caller:SteamID(), caller)
  local balanceamount = getbankbalance(caller:SteamID(), caller)
  print(balanceamount)
  net.Start("BANKER_REQUEST_INTERFACE")
  net.WriteInt(balanceamount,32)
  net.Send(caller)

end

function getIsOnCoolDown()
  return IsOnCoolDown
end

function setIsOnCoolDown(bool)
  IsOnCoolDown = bool
end



//Function checks if player has data for bank account balance. If no balance exists, it resets balance to 0.
function new_bank_account(SteamID, ply)
  if(ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) == -1) then
    ply:SetPData("BANKER_ADDON_BANK_BALANCE", 0)
  else
    print("Bank account already exists, no data changed.")
  end

end

//Returns player's Bank balance
//TESTING FUNCTION, DO NOT USE IN LIVE VERSION
function getbankbalance(SteamID, ply)
   local amount = ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1)
   print(amount)
   return amount
 end

//This function will set a player's bank balance to a user defined amount.
//TESTING FUNCTION, DO NOT USE IN LIVE VERSION
 function setbankbalance(SteamID, ply, amount)
   if(ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) != -1) then
    ply:SetPData("BANKER_ADDON_BANK_BALANCE", amount)
  else
    print("Error setting bank balance. User either does not have a bank account or another error has occured.")
  end

 end

//Function will deposit money into the account.
//TESTING FUNCTION, DO NOT USE IN LIVE VERSION
 function bankdeposit(SteamID, ply, amount)
   if(ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) != -1) then
    ply:SetPData("BANKER_ADDON_BANK_BALANCE", amount + ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1))
  else
    print("Error depositing to bank. User either does not have a bank account or another error has occured.")
  end
end

//Function handles withdraw requests from client.
-- After receiving the request from a client, it reads in the withdraw amount,
-- and checks to make sure that the player can withdraw that amount. If the
-- player has enough money in their account, the withdraw will happen. If not
-- the function will return a client request to send an error message.
net.Receive("BANK_WITHDRAW_REQUEST", function(len, ply)
  local withamount = net.ReadInt(32)
  local pocket = tonumber(ply:getDarkRPVar("money"))
  local balance = ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1)

  if(balance - withamount >= 0 && balance != 0) then
    ply:setDarkRPVar("money", pocket + withamount)
    ply:SetPData("BANKER_ADDON_BANK_BALANCE", ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) - withamount)
    net.Send(ply)
    net.Start("BANK_WITHDRAW_CONFIRMED_MESSAGE")
    net.WriteInt(withamount, 32)
    net.WriteInt(ply:GetPData("BANKER_ADDON_BANK_BALANCE"),32)
    net.Send(ply)
  else
    net.Start("BANK_NOT_ENOUGH_FUNDS_ERROR")
    net.Send(ply)
  end

end)

//Function handles withdraw requests from client.
-- After receiving the request from a client, it reads in the deposit amount,
-- and checks to make sure that the player can deposit that amount. If the
-- player has enough money on their player, the deposit will happen. If not
-- the function will return a client request to send an error message.
net.Receive("BANK_DEPOSIT_REQUEST", function(len, ply)
  local depoamount = net.ReadInt(32)
  local pocket = tonumber(ply:getDarkRPVar("money"))

  if(depoamount <= pocket && pocket >= 0 && ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) + depoamount <= CONFIG_BANK_MAX_LIMIT) then
    ply:setDarkRPVar("money", pocket - depoamount)
    ply:SetPData("BANKER_ADDON_BANK_BALANCE", ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) + depoamount)
    net.Send(ply)
    net.Start("BANK_DEPOSIT_CONFIRMED_MESSAGE")
    net.WriteInt(depoamount, 32)
    net.WriteInt(ply:GetPData("BANKER_ADDON_BANK_BALANCE"),32)
    net.Send(ply)
  elseif(ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) + depoamount > CONFIG_BANK_MAX_LIMIT) then
    net.Start("BANK_FULL_ERROR_ERROR")
    net.WriteInt(ply:GetPData("BANKER_ADDON_BANK_BALANCE"), 32)
    net.Send(ply)
  else
    net.Start("BANK_NOT_ENOUGH_FUNDS_ERROR")
    net.Send(ply)
  end

end)

//Handles client's request to Rob a Bank
-- Spawns money bag into world, makes player wanted, and alerts all bank security
-- that the bank is being robbed.
net.Receive("BANKER_SEND_SILENT_ALARM", function(len, ply)

  if(getIsOnCoolDown() == false) then
    local moneybag = ents.Create("banker_money_bag")
    moneybag:SetModel("models/props_c17/BriefCase001a.mdl")

    local offset = Vector(0, -20, 0)
    moneybag:SetPos(ply:GetShootPos() + offset)
    moneybag:Spawn()

    reason = "Robbing Bank"

    ply:setDarkRPVar("wanted", true)
    ply:setDarkRPVar("wantedReason", reason)
    local actorNick = "by the Server"
    local centerMessage = DarkRP.getPhrase("wanted_by_police", ply:Nick(), reason, actorNick)
    local printMessage = DarkRP.getPhrase("wanted_by_police_print", actorNick, ply:Nick(), reason)

    for _, ply2 in ipairs(player.GetAll()) do
      ply2:PrintMessage(HUD_PRINTCENTER, centerMessage)
      ply2:PrintMessage(HUD_PRINTCONSOLE, printMessage)
    end

    local table = {}

    ply:EmitSound("vo/npc/vortigaunt/giveover.wav")

    for k, v in pairs(player.GetAll()) do
      if(team.GetName(v:Team()) == "Bank Security") then
        net.Start("BANKER_REQUEST_SILENT_ALARM_PLAY")
        net.Send(v)
      end
    end

    timer.Simple(1.45, function() ply:EmitSound("vo/npc/male01/help01.wav") end)
    setIsOnCoolDown(true)
    timer.Create("BANKER_ROBBERY_COOLDOWN", CONFIG_ROBBERY_COOLDOWN, 1, function() setIsOnCoolDown(false) end)
    timer.Start("BANKER_ROBBERY_COOLDOWN")

  else
    net.Start("BANKER_ROBBERY_ON_COOLDOWN_WARNING")
    net.WriteInt(timer.TimeLeft("BANKER_ROBBERY_COOLDOWN"), 32)
    net.Send(ply)
  end
end)

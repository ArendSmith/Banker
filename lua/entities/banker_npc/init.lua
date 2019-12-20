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

function ENT:Initialize()
  self:SetModel("models/player/magnusson.mdl")
  self:SetHullType(HULL_HUMAN)
  self:SetHullSizeNormal()
  self:SetNPCState(NPC_STATE_SCRIPT)
  self:SetSolid(SOLID_BBOX)
  self:CapabilitiesAdd(CAP_ANIMATEDFACE)
  self:SetUseType(SIMPLE_USE)
  self:DropToFloor()

end

function ENT:AcceptInput(name, activator, caller)
  if name == "Use" and caller:IsPlayer() then
    activator:SendLua( "chat.AddText('[Banker] Welcome to Banker UI 0.1 by Ren')")
  end

  new_bank_account(caller:SteamID(), caller)

  local balanceamount = getbankbalance(caller:SteamID(), caller)

  print(balanceamount)

  net.Start("BANKER_REQUEST_INTERFACE")
  net.WriteInt(balanceamount,32)
  net.Send(caller)

  //Test Functions
  -- bankdeposit(caller:SteamID(), caller, 1000)
  -- getbankbalance(caller:SteamID(), caller)


end



//Function checks if player has data for bank account balance. If no balance exists, it resets balance to 0.
function new_bank_account(SteamID, ply)
  if(ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) == -1) then
    ply:SetPData("BANKER_ADDON_BANK_BALANCE", 0)
  else
    print("Bank account already exists, no data changed.")
  end

end

function getbankbalance(SteamID, ply)
   //print(ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1))
   local amount = ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1)
   print(amount)
   return amount
 end

//This function will set a player's bank balance to a user defined amount.
 function setbankbalance(SteamID, ply, amount)
   if(ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) != -1) then
    ply:SetPData("BANKER_ADDON_BANK_BALANCE", amount)
  else
    print("Error setting bank balance. User either does not have a bank account or another error has occured.")
  end

 end

//Function will deposit money into the account.
//Fixes need: NEEDS TO CHECK A CAP
 function bankdeposit(SteamID, ply, amount)
   if(ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) != -1) then
    ply:SetPData("BANKER_ADDON_BANK_BALANCE", amount + ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1))
  else
    print("Error depositing to bank. User either does not have a bank account or another error has occured.")
  end
end

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

net.Receive("BANK_DEPOSIT_REQUEST", function(len, ply)
  local depoamount = net.ReadInt(32)
  local pocket = tonumber(ply:getDarkRPVar("money"))

  if(depoamount < pocket && pocket != 0 && ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) + depoamount <= 2000000000) then
    ply:setDarkRPVar("money", pocket - depoamount)
    ply:SetPData("BANKER_ADDON_BANK_BALANCE", ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) + depoamount)
    net.Send(ply)
    net.Start("BANK_DEPOSIT_CONFIRMED_MESSAGE")
    net.WriteInt(depoamount, 32)
    net.WriteInt(ply:GetPData("BANKER_ADDON_BANK_BALANCE"),32)
    net.Send(ply)
  elseif(ply:GetPData("BANKER_ADDON_BANK_BALANCE", -1) + depoamount > 2000000000) then
    net.Start("BANK_FULL_ERROR_ERROR")
    net.WriteInt(ply:GetPData("BANKER_ADDON_BANK_BALANCE"), 32)
    net.Send(ply)
  else
    net.Start("BANK_NOT_ENOUGH_FUNDS_ERROR")
    net.Send(ply)
  end

end)

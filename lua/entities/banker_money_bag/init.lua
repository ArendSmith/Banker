AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("cl_init.lua")



util.AddNetworkString("BANKER_MONEY_BAG_TIMER_ERROR")
util.AddNetworkString("BANKER_MONEY_BAG_SUCCESS_MESSAGE")
util.AddNetworkString("BANKER_WRONG_JOB_ERROR")
IsOnUseCoolDown = false

//When the money bag is spawned by the bank teller after being robbed. The entity
-- creates a timer that lasts for 3 minutes. When the time is over, it changes
-- the boolean check to allow players to open the money bag and receive their
-- reward.
function ENT:Initialize()
  self:SetModel("models/props_c17/BriefCase001a.mdl")

  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)

  local phys = self:GetPhysicsObject()

  if phys:IsValid() then
    phys:Wake()

  end

  self.CanBeOpened = false

  timer.Create("BAG_OPEN_TIMER", CONFIG_MONEY_BAG_TIMER, 1, function() self.CanBeOpened = true end)

  timer.Start("BAG_OPEN_TIMER")

end

//This function checks if the user can open the money bag, if yes it awards the money
-- and removes the entity. If not it prompts the user the remaining time left till it
-- can be open.
function ENT:AcceptInput(name, activator, caller)

  if(self.CanBeOpened == true && team.GetName(caller:Team()) == "Thief") then
    caller:addMoney(CONFIG_MONEY_BAG_THIEF_REWARD)
    self:Remove()
    net.Start("BANKER_MONEY_BAG_SUCCESS_MESSAGE")
    net.Send(caller)
  elseif(self.CanBeOpened == true && team.GetName(caller:Team()) == "Bank Security") then
    caller:addMoney(CONFIG_MONEY_BAG_SECURITY_REWARD)
    self:Remove()
    net.Start("BANKER_MONEY_BAG_SUCCESS_MESSAGE")
    net.Send(caller)
  elseif(self.CanBeOpened == false && team.GetName(caller:Team()) == "Thief") then
    net.Start("BANKER_MONEY_BAG_TIMER_ERROR")
    net.WriteInt(timer.TimeLeft("BAG_OPEN_TIMER"),32)
    net.Send(caller)
  elseif(self.CanBeOpened == false && team.GetName(caller:Team()) == "Bank Security") then
    net.Start("BANKER_MONEY_BAG_TIMER_ERROR")
    net.WriteInt(timer.TimeLeft("BAG_OPEN_TIMER"),32)
    net.Send(caller)
  else
    net.Start("BANKER_WRONG_JOB_ERROR")
    net.Send(caller)
  end

end

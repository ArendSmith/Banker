include("shared.lua")

//Draws the ingame model and puts text over the top of the model.
function ENT:Draw()

  self:DrawModel()

  local Pos = self:GetPos()
  local Ang = self:GetAngles()

  surface.SetFont("HUDNumber5")
  local text = "Money Bag"
  local owner = "TIMER"
  local TextWidth = surface.GetTextSize(text)
  local TextWidth2 = surface.GetTextSize(owner)

  Ang:RotateAroundAxis(Ang:Forward(), 90)

  cam.Start3D2D(Pos + Ang:Right() * -8.5, Ang, 0.11)
      draw.WordBox(2, -TextWidth * 0.5, -30, text, "HUDNumber5", Color(140, 0, 0, 100), Color(255, 255, 255, 255))
  cam.End3D2D()

end

//Handles communication from server to prompt HUD messages.
net.Receive(("BANKER_MONEY_BAG_TIMER_ERROR"), function()
  notification.AddLegacy("Bag opens in " .. net.ReadInt(32) .." seconds! Secure your loot!", NOTIFY_ERROR, 3)
  surface.PlaySound("buttons/button10.wav")
end)

net.Receive(("BANKER_MONEY_BAG_SUCCESS_MESSAGE"), function()
  local player = LocalPlayer()

  if(team.GetName(player:Team()) == "Thief") then
    notification.AddLegacy("You stole $" .. CONFIG_MONEY_BAG_THIEF_REWARD .. "!", NOTIFY_GENERIC, 3)
    surface.PlaySound("vo/Citadel/al_success_yes.wav")

  elseif(team.GetName(player:Team()) == "Bank Security") then
    notification.AddLegacy("You recovered the stolen money! You receive a $" .. CONFIG_MONEY_BAG_SECURITY_REWARD .. " bonus!" , NOTIFY_GENERIC, 3)
    surface.PlaySound("vo/Citadel/al_success_yes.wav")

  else
    notification.AddLegacy("You shouldn't be rewarded, but some how you were! [DEV ERROR]", NOTIFY_ERROR, 3)
    surface.PlaySound("buttons/button10.wav")
  end
end)

net.Receive(("BANKER_WRONG_JOB_ERROR"), function()
  notification.AddLegacy("This item has nothing to do with your job type!", NOTIFY_ERROR, 3)
  surface.PlaySound("buttons/button10.wav")

end)

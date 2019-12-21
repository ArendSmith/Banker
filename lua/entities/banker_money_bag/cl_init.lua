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
  notification.AddLegacy("You stole $500!", NOTIFY_GENERIC, 3)
  surface.PlaySound("vo/Citadel/al_success_yes.wav")
end)

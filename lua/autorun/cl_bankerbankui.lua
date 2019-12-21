//This function handles all the GUI elements of the Bank.
-- Users will input an amount into the DNumberWang and use the buttons to decide
-- Whether they want to deposit or withdraw that amount. When the button is clicked
-- the client will request the server to check if the user can perform that action
-- if it can, the action will be performed server side, and return a message to the
-- client for a successful action. If not the server will return a message to the
-- client for a failed action.
function launchbankui()

  local balanceamount = net.ReadInt(32)
  local player = LocalPlayer()

  local frame = vgui.Create("DFrame")
  frame:SetSize(300,200)
  frame:Center()
  frame:SetVisible(true)
  frame:MakePopup()
  frame:SetTitle("Banker UI 0.1 by Ren")

  local userinput = vgui.Create("DNumberWang", frame)
  userinput:SetPos(120, 120)
  userinput:SetMax(2000000000)

  local Button_Deposit = vgui.Create("DButton", frame)
  Button_Deposit:SetText("Deposit")
  Button_Deposit:SetSize(100,30)
  Button_Deposit:SetPos(150,150)
  Button_Deposit.DoClick = function(Button_Deposit)
    if(userinput:GetValue() < 2000000000) then
      net.Start("BANK_DEPOSIT_REQUEST")
        net.WriteInt(userinput:GetValue(),32)
      net.SendToServer()
      frame:Close()
    else
      print("Error Test")
    end
  end

  local Button_Withdraw = vgui.Create("DButton", frame)
  Button_Withdraw:SetText("Withdraw")
  Button_Withdraw:SetSize(100,30)
  Button_Withdraw:SetPos(50,150)
  Button_Withdraw.DoClick = function(Button_Withdraw)
    if(userinput:GetValue() < 2000000000) then
      net.Start("BANK_WITHDRAW_REQUEST")
        net.WriteInt(userinput:GetValue(),32)
      net.SendToServer()
      frame:Close()
    else
      print("Error Test")
    end
  end



  local Bank_Text = vgui.Create("DLabel", frame)
  Bank_Text:SetPos(22,71)
  Bank_Text:SetFont("DermaLarge")
  Bank_Text:SizeToContents()
  Bank_Text:SetText("$")

  local Bank_Text2 = vgui.Create("DLabel", frame)
  Bank_Text2:SetPos(40,70)
  Bank_Text2:SetSize(250,35)
  Bank_Text2:SetFont("DermaLarge")
  Bank_Text2:SetWrap(true)
  Bank_Text2:SetText(balanceamount)

  local Bank_Text3 = vgui.Create("DLabel", frame)
  Bank_Text3:SetPos(22,30)
  Bank_Text3:SetSize(250,35)
  Bank_Text3:SetFont("DermaLarge")
  Bank_Text3:SetWrap(true)
  Bank_Text3:SetText("Bank Balance:")
//  weapon_deagle2 weapon_fiveseven2 weapon_glock2 weapon_m42 weapon_mac102 weapon_mp52 weapon_p2282 weapon_pumpshotgun2
  local Button_Robbery = vgui.Create("DButton", frame)
  Button_Robbery:SetText("Rob Bank")
  Button_Robbery:SetSize(60,30)
  Button_Robbery:SetPos(225,27)
  Button_Robbery:SetVisible(false)
  if (team.GetName(player:Team()) == "Thief") then
    if(player:GetActiveWeapon():GetClass() == "weapon_ak472" or player:GetActiveWeapon():GetClass() == "weapon_deagle2" or player:GetActiveWeapon():GetClass() == "weapon_fiveseven2"
     or player:GetActiveWeapon():GetClass() == "weapon_glock2" or player:GetActiveWeapon():GetClass() == "weapon_m42" or player:GetActiveWeapon():GetClass() == "weapon_mac102"
     or player:GetActiveWeapon():GetClass() == "weapon_mp52" or player:GetActiveWeapon():GetClass() == "weapon_p2282" or player:GetActiveWeapon():GetClass() == "weapon_pumpshotgun2") then
      Button_Robbery:SetVisible(true)
    end
  end
  Button_Robbery.DoClick = function(Button_Robbery)
    net.Start("BANKER_SEND_SILENT_ALARM")
    net.SendToServer()
  end

end

//The following functions handle communication between server and client.
net.Receive("BANKER_REQUEST_INTERFACE", launchbankui)
net.Receive( "BANK_NOT_ENOUGH_FUNDS_ERROR", function()
  notification.AddLegacy("You do not have enough money to perform this action.", NOTIFY_ERROR, 3)
  surface.PlaySound("buttons/button10.wav")
end)
net.Receive( "BANK_FULL_ERROR_ERROR", function()
  notification.AddLegacy("Your bank is full.", NOTIFY_ERROR, 3)
  surface.PlaySound("buttons/button10.wav")
end)

net.Receive(("BANK_DEPOSIT_CONFIRMED_MESSAGE"), function()
  notification.AddLegacy("You've deposited: $" .. net.ReadInt(32), NOTIFY_GENERIC, 3)
  surface.PlaySound("buttons/button14.wav")
end)

net.Receive(("BANK_WITHDRAW_CONFIRMED_MESSAGE"), function()
  notification.AddLegacy("You've Withdrawn: $" .. net.ReadInt(32), NOTIFY_GENERIC, 3)
  surface.PlaySound("buttons/button14.wav")
end)

net.Receive(("BANKER_REQUEST_SILENT_ALARM_PLAY"), function()
  notification.AddLegacy("A silent alarm has been tripped by a Banker, please respond!", NOTIFY_GENERIC, 3)
  surface.PlaySound("HL1/fvox/beep.wav")
end)

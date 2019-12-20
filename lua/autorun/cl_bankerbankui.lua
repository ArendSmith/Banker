function launchbankui()

  local balanceamount = net.ReadInt(32)

  local frame = vgui.Create("DFrame")
  frame:SetSize(300,200)
  frame:Center()
  frame:SetVisible(true)
  frame:MakePopup()
  frame:SetTitle("Banker UI 0.1 by Ren")

  local userinput = vgui.Create("DNumberWang", frame)
  userinput:Center()
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
  Bank_Text:SetPos(22,47)
  Bank_Text:SetFont("DermaLarge")
  Bank_Text:SizeToContents()
  Bank_Text:SetText("$")

  local Bank_Text2 = vgui.Create("DLabel", frame)
  Bank_Text2:SetPos(40,45)
  Bank_Text2:SetSize(250,35)
  Bank_Text2:SetFont("DermaLarge")
  //Bank_Text2:SizeToContents()
  Bank_Text2:SetWrap(true)
  Bank_Text2:SetText(balanceamount)

end

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

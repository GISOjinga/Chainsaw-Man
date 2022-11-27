local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local types = require(ReplicatedStorage.Source.Types)
local knit = require(ReplicatedStorage.Packages.Knit)

local MoneyController = knit.CreateController({
    Name = "MoneyController",
})



function MoneyController:KnitStart()
    local moneyService = knit.GetService("MoneyService")
    
    local function PrintMoney(money)
        print(money)
    end

    moneyService.MoneyChanged:Connect(PrintMoney)
    moneyService:GetMoney(Players.LocalPlayer):andThen(PrintMoney):catch(warn)
end

return MoneyController
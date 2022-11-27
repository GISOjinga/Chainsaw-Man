local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- Create the service:
local MoneyService = Knit.CreateService({
    Name = "MoneyService",
    Client = {
        MoneyChanged = Knit.CreateSignal()::RBXScriptSignal,
    },
})

function MoneyService.Client:GetMoney(player:Player)
    return self.Server:GetMoney(player)
end

function MoneyService:GetMoney(player:Player):number
    self.Client.MoneyChanged:Fire(player, 10)
    
    return 0
end

function MoneyService:GiveMoney(player, amount)
    
end

return MoneyService
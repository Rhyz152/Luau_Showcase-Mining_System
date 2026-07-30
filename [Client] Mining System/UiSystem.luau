--// Services
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

--// Connections
local Connections = ReplicatedStorage:WaitForChild("Connections")
local DataConnections = Connections:WaitForChild("DataConnections")
local ClientUpdateRocks = DataConnections:WaitForChild("ClientUpdateRocks")
local RequestPlayerData = DataConnections:WaitForChild("RequestPlayerData")

const module = {}

--// Update AmountLabel text to new amount updated
const function UpdateUi(NewAmount: number)
	const Player: Player = Players.LocalPlayer
	const PlayerGui = Player:WaitForChild("PlayerGui")
	
	-- Ui elements
	const HudGui = PlayerGui:WaitForChild("HudGui")
	
	const RocksFrame = HudGui:WaitForChild("RocksFrame")
	if not RocksFrame then warn("RocksFrame not found"); return end
	
	const AmountLabel: TextLabel = RocksFrame:WaitForChild("AmountLabel")
	if not AmountLabel then warn("AmountLabel not found"); return end
	
	AmountLabel.Text = "Rocks: "..tostring(NewAmount)
end

function module.Start()
    --// Update Ui when rocks updated
    ClientUpdateRocks.OnClientEvent:Connect(function(NewAmount: number)
    	UpdateUi(NewAmount)
    end)

    task.defer(function()
        RequestPlayerData:FireServer()
    end)
end

return module
--// Services
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

--// Connections
local Connections = ReplicatedStorage:FindFirstChild("Connections")
if not Connections then
    Connections = Instance.new("Folder")
    Connections.Name = "Connections"
    Connections.Parent = ReplicatedStorage
end

local DataConnections = Connections:FindFirstChild("DataConnections")
if not DataConnections then
    DataConnections = Instance.new("Folder")
    DataConnections.Name = "DataConnections"
    DataConnections.Parent = Connections
end

local function EnsureBindableEvent(parent, name)
    local ExistingEvent = parent:FindFirstChild(name)
    if ExistingEvent then
        return ExistingEvent
    end

    local NewEvent = Instance.new("BindableEvent")
    NewEvent.Name = name
    NewEvent.Parent = parent
    return NewEvent
end

local function EnsureRemoteEvent(parent, name)
    local ExistingEvent = parent:FindFirstChild(name)
    if ExistingEvent then
        return ExistingEvent
    end

    local NewEvent = Instance.new("RemoteEvent")
    NewEvent.Name = name
    NewEvent.Parent = parent
    return NewEvent
end

local UpdateRocksAmount = EnsureBindableEvent(DataConnections, "ServerAddRocks")
local ClientUpdateRocks = EnsureRemoteEvent(DataConnections, "ClientUpdateRocks")
local RequestPlayerData = EnsureRemoteEvent(DataConnections, "RequestPlayerData")

-- DataStore
const DataStore = require(script.Parent.DataStore)

const module = {}

function module.Start()
    print("[DataService]: Starting player data service")

    Players.PlayerAdded:Connect(function(Player: Player)
        local PlayerData = DataStore.RetrieveData(Player)
        if not PlayerData then
            DataStore.SetData(Player)
            PlayerData = DataStore.RetrieveData(Player)
        end

        if PlayerData then
            task.defer(function()
                if Player.Parent then
                    ClientUpdateRocks:FireClient(Player, PlayerData.Rocks)
                end
            end)
        end
    end)

    RequestPlayerData.OnServerEvent:Connect(function(Player: Player)
        local PlayerData = DataStore.RetrieveData(Player)
        if not PlayerData then
            DataStore.SetData(Player)
            PlayerData = DataStore.RetrieveData(Player)
        end

        if PlayerData then
            ClientUpdateRocks:FireClient(Player, PlayerData.Rocks)
        end
    end)

    Players.PlayerRemoving:Connect(function(Player: Player)
        DataStore.UpdateData(Player)
        DataStore.RemoveSessionData(Player)
    end)

    UpdateRocksAmount.Event:Connect(function(Player: Player, Amount: number)
        DataStore.AddRocks(Player, Amount)

        local SessionData = DataStore.GetSessionData(Player)
        if SessionData then
            task.defer(function()
                if Player.Parent then
                    ClientUpdateRocks:FireClient(Player, SessionData.Rocks)
                end
            end)
        end
    end)
end

return module
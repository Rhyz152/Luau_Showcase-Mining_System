--// Services
const DataStoreService: DataStoreService = game:GetService("DataStoreService")

-- data
const PlayerData: DataStore = DataStoreService:GetDataStore("PlayerData")

local module = {}

const Data: { [Player]: any } = {}

const DataTemplate: {} = {
	Rocks = 0,
}

-- initialise player's data
function module.SetData(Player: Player)
	local InitialData = table.clone(DataTemplate)
	Data[Player] = InitialData

	const SetSuccess, SetResult = pcall(function()
		PlayerData:SetAsync(tostring(Player.UserId), InitialData)
	end)
	
	if not SetSuccess then
		warn("Failed to set data for "..Player.Name.. " because "..SetResult)
		return false
	end
	
	return true
end

-- retrieve player's data, set data if none
function module.RetrieveData(Player: Player)
	const RetrieveSuccess, RetrieveResult = pcall(function()
		return PlayerData:GetAsync(tostring(Player.UserId))
	end)
	
	if not RetrieveSuccess then
		warn("Failed to retrieve data for "..Player.Name.." because "..RetrieveResult)
		return nil
	end
	
	-- if they are a new player, clone the data template for them
	if not RetrieveResult then
		Data[Player] = table.clone(DataTemplate)
	else
		-- their data is what ProfileData retireved
		Data[Player] = RetrieveResult
	end
	
	return Data[Player]
end

-- update player's data to new data at the end
function module.UpdateData(Player: Player)
	if not Data[Player] then
		warn("No data found in "..Player.Name.."'s session to save")
		return
	end
	
	const UpdateSuccess, UpdateResult = pcall(function()
		PlayerData:SetAsync(tostring(Player.UserId), Data[Player])
	end)
	
	if not UpdateSuccess then
		warn("Failed to update data for "..Player.Name.." because "..UpdateResult)
		return
	end
end

function module.AddRocks(Player: Player, Amount: number)
	if not Data[Player] then
		warn("Failed to find data for "..Player.Name)
		return
	end
	
	Data[Player].Rocks += Amount
	
	return Data[Player]
end

function module.RemoveSessionData(Player: Player)
	Data[Player] = nil
end

function module.GetSessionData(Player: Player)
	return Data[Player]
end

return module
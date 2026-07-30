--// Services
const ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Shared
const SharedUtils = ReplicatedStorage.Shared.SharedUtils
const ObjectPoolUtils = SharedUtils.ObjectPoolUtils
const ObjectPoolHandler = require(ObjectPoolUtils.ObjectPoolHandler)

--// Assets
const Rock = ReplicatedStorage.Assets.Rock
const RocksFolder = workspace.Rocks
const RockSpawns = workspace.RockSpawns

const module = {}

--// Vars
const RespawnDelay: number = 1.5 -- delay before rock spawn
local IsRespawning: boolean = false -- debounce, avoids multiple events that respawn rocks
local RockPool

-- Rocks Object Pool
const function GetRockPool(Amount: number)
	if RockPool then return RockPool end

	const function OnCreate(Rock)
		Rock.Parent = RocksFolder
	end

	const function OnFree(Rock)
		Rock.Parent = nil
	end

	RockPool = ObjectPoolHandler.Construct(Rock, Amount, OnCreate, nil, OnFree)
	return RockPool
end

function module.Start()
    --// Function to loop through RocksFolder and detect if no children, then respawn the rocks after delay
    const function RespawnRocks()
    	task.wait(RespawnDelay) -- delay
		const AmountRocks: number = #RocksFolder:GetChildren()
    	if AmountRocks > 0 or IsRespawning then return end   --determine whether there are rocks
    	IsRespawning = true
    
    	-- get the possible spawn locations
    	for _, Spawn in pairs(RockSpawns:GetChildren()) do
    		if not Spawn:IsA("BasePart") then continue end
			
			const Amount: number = #RockSpawns:GetChildren()
    		const PossibleCrame: CFrame = Spawn.CFrame * CFrame.Angles(0, math.rad(math.random(15, 85)), 0) -- rotate them randomly
        
    		-- Get a Rock
			const RockObj = GetRockPool(Amount)
			const NewRock = RockObj:Get()

			NewRock.CFrame = PossibleCrame
			NewRock.Name = "Rock"
    	end
    
    	IsRespawning = false
    end

    -- initalise spawn
    RespawnRocks()

    -- attempt to respawn rocks when a rock is destroyed
    RocksFolder.ChildRemoved:Connect(RespawnRocks)
end

return module
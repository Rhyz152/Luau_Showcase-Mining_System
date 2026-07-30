--// Services
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const CollectionService = game:GetService("CollectionService")

--// Shared
const Shared = ReplicatedStorage.Shared
const SharedUtils = Shared.SharedUtils
const CooldownUtils = SharedUtils.CooldownUtils
local ObjectPoolHandler = require(ReplicatedStorage.Shared.SharedUtils.ObjectPoolUtils.ObjectPoolHandler)
const CooldownHandler = require(CooldownUtils.CooldownHandler)
local CFrameBuffer = require(Shared.Buffers.MiningSystemBuff.Buffer)

--// Connections
local Connections = ReplicatedStorage:FindFirstChild("Connections")
local DataConnections = Connections:FindFirstChild("DataConnections")
local MiningConnections = Connections:FindFirstChild("MiningConnections")
local ServerAddRocks = DataConnections:FindFirstChild("ServerAddRocks")
local ClientActivateEvent = MiningConnections:FindFirstChild("ClientActivateEvent")

--// Main
const module = {}

-- Vars
const LastRequest: { [Player]: number} = {}
const AlreadyHit: {[Instance]: boolean} = {}
const HitTimes: {[Instance]: number} = {}
const Part: BasePart = Instance.new("Part")
local HitboxPool

-- Hitbox Pool
const function GetHitboxPool()
	if HitboxPool then return HitboxPool end

	const function OnCreate(Hitbox)
		Hitbox.Parent = workspace
	end

	const function OnFree(Hitbox)
		Hitbox.Parent = nil
	end

	HitboxPool = ObjectPoolHandler.Construct(Part, 1, OnCreate, nil, OnFree)
	return HitboxPool
end

--// Mining system
function module.Start()
    ClientActivateEvent.OnServerEvent:Connect(function(Player: Player)
    	-- Cooldown
    	const IsCooldown = CooldownHandler.CheckCooldown(Player, 1, LastRequest)
        if IsCooldown then return end

    	-- Character instances
    	const Character = Player.Character or Player.CharacterAdded:Wait()
    	const HumanoidRootPart: BasePart = Character:WaitForChild("HumanoidRootPart")
    	if not HumanoidRootPart then warn("HumanoidRootPart not found in "..Character.Name); return end

		const HitboxObj = GetHitboxPool() -- get class
		const Hitbox = HitboxObj:Get() -- get object
		-- Props
		Hitbox.Anchored = true
		Hitbox.CanCollide = false
		Hitbox.CanQuery = true
		Hitbox.CanTouch = false
		Hitbox.Transparency = .35
		Hitbox.Color = Color3.fromRGB(255, 0, 0)
		Hitbox.Material = Enum.Material.Neon
		Hitbox.CastShadow = false
		Hitbox.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
		Hitbox.Size = Vector3.new(4, 6, 4)

		-- keep it visible for .25s then return it to the pool
		task.delay(.25, function()
			if Hitbox and Hitbox.Parent then
				HitboxObj:Free(Hitbox)
			end
		end)

    	-- spatial query everything inside of hitbox
    	const HitboxParams: OverlapParams = OverlapParams.new()
    	HitboxParams.FilterType = Enum.RaycastFilterType.Exclude
    	HitboxParams.FilterDescendantsInstances = {Character, Hitbox}
        
    	for _, Part: BasePart in pairs(workspace:GetPartBoundsInBox(Hitbox.CFrame, Hitbox.Size, HitboxParams)) do
    		const PartTags = CollectionService:GetTags(Part)
        
    		for _, Tag in pairs(PartTags) do
    			if Tag ~= "Rock" then continue end -- check if it has the "Rock" attribute (tag editor)

    			AlreadyHit[Part] = true -- make it hit, avoids it being queried multiple times

                -- Destroy logic: if there is HitTimes[Part] then increment 1, else make it 1
    			if HitTimes[Part] then
    				HitTimes[Part] += 1
    			else
    				HitTimes[Part] = 1
    			end
            
                -- destroy after 3 hits
    			if HitTimes[Part] == 3 then
    				Part:Destroy()
    				HitTimes[Part] = nil
    				ServerAddRocks:Fire(Player, 1) -- comminucate to other server side script to add rocks to the player's data
    			end

				-- send in buffer to client (visuals)
				CFrameBuffer.CFrameVal.sendTo({CframeVal = Part.CFrame}, Player)
			end
		end
	end)
end

return module
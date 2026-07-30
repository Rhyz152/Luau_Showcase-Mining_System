--!nonstrict
--// Services
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const StarterPlayer = game:GetService("StarterPlayer")
const Players = game:GetService("Players")

--// Shared
const Shared = ReplicatedStorage.Shared
const SharedUtils = Shared.SharedUtils
const CooldownUtils= SharedUtils.CooldownUtils
const ObjectPoolUtils = SharedUtils.ObjectPoolUtils
const CooldownHandler = require(CooldownUtils.CooldownHandler)
const ObjectPoolHandler = require(ObjectPoolUtils.ObjectPoolHandler)
const CFrameBuffer = require(Shared.Buffers.MiningSystemBuff.Buffer)

--// Connections
local Connections = ReplicatedStorage:FindFirstChild("Connections")
local MiningConnections = Connections:FindFirstChild("MiningConnections")
local ClientActivateEvent = MiningConnections:WaitForChild("ClientActivateEvent")

--// Client
const ClientUtils = StarterPlayer.StarterPlayerScripts.Client.ClientUtils
const AnimationUtils = ClientUtils.AnimationUtils
const InputDetectionUtils = ClientUtils.InputDetectionUtils
const AnimationHandler = require(AnimationUtils.AnimationHandler)
const InputDetectionHandler = require(InputDetectionUtils.InputDetectionHandler)

--// Assets
local Assets = ReplicatedStorage:FindFirstChild("Assets")
local Pickaxe = Assets:FindFirstChild("Pickaxe")
local SwingAnim = Assets:FindFirstChild("SwingAnim")
local HitSfx = Assets:FindFirstChild("HitSfx")
local HitVfxPart = Assets:FindFirstChild("HitVfxPart")

const module = {}

--// Vars
const Player: Player = Players.LocalPlayer
const LastRequest: {} = {}
local _HasPickaxe: boolean  = false
local SfxPool
local VfxPool

-- Sfx Object Pool
const function GetSfxPool()
    if SfxPool then return SfxPool end

    const function OnCreate(SfxInstance)
        SfxInstance.Parent = Player.Character
    end
    const function OnFree(SfxInstance)
        SfxInstance.Parent = nil
    end

    SfxPool = ObjectPoolHandler.Construct(HitSfx, 1, OnCreate, nil, OnFree)
    return SfxPool
end

-- Vfx Object Pool
const function GetVfxPool()
    if VfxPool then return VfxPool end

    const function OnCreate(VfxPart)
        VfxPart.Parent = Player.Character
    end
    const function OnFree(VfxPart)
        VfxPart.Parent = nil
    end

    VfxPool = ObjectPoolHandler.Construct(HitVfxPart, 1, OnCreate, nil, OnFree)
    return VfxPool
end

--// Function to initialise the pickaxe to the player
const function PickaxeEquip(Character: Model)
	-- Character instances
	const Humanoid = Character:WaitForChild("Humanoid")
	if not Humanoid then warn("Humanoid not found"); return end
	
	const RightArm = Character:WaitForChild("Right Arm")
	if not RightArm then warn("Right Arm not found in "..Character.Name); return end
	
	-- Pickaxe cloning if no Pickaxe found in the character
	if _HasPickaxe or Character:FindFirstChild("Pickaxe") then return end
    
    local PlayerPickaxe = Pickaxe:Clone()
    PlayerPickaxe.Name = "Pickaxe"
    PlayerPickaxe.Parent = Character
	
	-- Handle variables
	const Handle: BasePart = PlayerPickaxe.PrimaryPart
	if not Handle then warn("Handle not found"); return end
	
	const Motor6D = Handle:FindFirstChild("Motor6D")
	if not Motor6D then warn("Motor6D not found"); return end
	
	const HandleCframeValue = Handle:FindFirstChild("HandleCframeVal")
	if not HandleCframeValue then warn("HandleCframeValue not found"); return end
	
	--- Motor 6D props
	Motor6D.Part0 = RightArm -- goes to the right arm
	Motor6D.Part1 = Handle
	Motor6D.C1 = HandleCframeValue.Value -- set the offset value to the value inside the cframe value
	_HasPickaxe = true
	
	-- cleanup pickaxe on death or leave
	Humanoid.Died:Connect(function()
		if PlayerPickaxe then
            PlayerPickaxe:Destroy()
            PlayerPickaxe = nil
            _HasPickaxe = false
		end
	end)
	Players.PlayerRemoving:Connect(function()
		if PlayerPickaxe then
            PlayerPickaxe:Destroy()
            PlayerPickaxe = nil
            _HasPickaxe = false
		end
	end)
end

--// Function to use the pickaxe
const function PickaxeActivate()
	-- Cooldown
	const IsOnCooldown: boolean = CooldownHandler.CheckCooldown(Player, 1, LastRequest)
	if IsOnCooldown then return end

	const Character = Player.Character or Player.CharacterAdded:Wait()
	
	--- Character instances
	const Humanoid: Humanoid = Character:WaitForChild("Humanoid")
	if not Humanoid then warn("Humanoid not found"); return end
	
	const Pickaxe: Model = Character:WaitForChild("Pickaxe")
	if not Pickaxe then warn("Pickaxe not found in "..Character.Name); return end
	
	if Humanoid.Health <= 0 then warn(Character.Name.." is dead"); return end
	
	-- Animation play instantly
    Humanoid.WalkSpeed = 0
	AnimationHandler.LoadAnimation(Character, "SwingAnim", SwingAnim.AnimationId, function(MarkerName)
        ClientActivateEvent:FireServer()
        task.wait(.5)
        Humanoid.WalkSpeed = 16
    end)
end

function module.Start()
    -- init pickaxe
    if Player.Character then
    	PickaxeEquip(Player.Character)
    end
    -- on respawn, create new pickaxe
    Player.CharacterAdded:Connect(PickaxeEquip)

    -- get the buffer's data
    CFrameBuffer.CFrameVal.listen(function(data: { CframeVal: CFrame })
        -- Sfx object pool
        if HitSfx and HitSfx:IsA("Sound") then
            const RockSfx = GetSfxPool()
            const RockHitSfx = RockSfx:Get()

            RockHitSfx:Play()
            RockHitSfx.Ended:Connect(function()
                RockSfx:Free(RockHitSfx)
            end)
        end

        -- Vfx object pool
        if HitVfxPart and HitVfxPart:IsA("BasePart") then
            const HitVfx = GetVfxPool()
            const NewHitVfxPart = HitVfx:Get()

            NewHitVfxPart.Anchored = true
            NewHitVfxPart.CFrame = data.CframeVal
            const Att0 = NewHitVfxPart:FindFirstChild("Att0")
            if not Att0 then warn("Att0 not found"); return end

            const Emitter: ParticleEmitter = Att0:FindFirstChild("Emitter")
            if not Emitter then warn("Emitter not found"); return end

            Emitter:Emit(1)
            task.defer(function()
                task.wait(.5)
                HitVfx:Free(NewHitVfxPart)
            end)
        end
    end)

    -- input detection
    InputDetectionHandler.DetectInputType(Enum.UserInputType.MouseButton1, function()
        PickaxeActivate()
    end)
end

return module
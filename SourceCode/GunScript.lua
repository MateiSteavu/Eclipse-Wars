local Player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera;
local EquippedGun = Player:WaitForChild("PlayerGui").EquippedGun

local mouse = Player:GetMouse()

local ChosenGun = Player:WaitForChild("ChosenGun")
local ChosenSec = Player:WaitForChild("ChosenSec")

local viewModel = camera:WaitForChild("viewModel")
local Primary = viewModel:WaitForChild(ChosenGun.Value)
local Secondary = viewModel:WaitForChild(ChosenSec.Value)

local crosshair = Player:WaitForChild("PlayerGui").Menu.Crosshair
local hitmarker = crosshair.Hitmarkers

local humanoid = Player.Character.Humanoid

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local BulletsLeft = ReplicatedStorage:WaitForChild("FetchBulletsLeft")
local EquipAnimation = ReplicatedStorage:WaitForChild("EquipAnimation")
local Headshot = ReplicatedStorage:WaitForChild("Headshot")
local Bodyshot = ReplicatedStorage:WaitForChild("BodyDMG")
local reload2 = ReplicatedStorage:WaitForChild("Reload")
local UnequipAnimation = ReplicatedStorage:WaitForChild("UnequipAnimation")
local ShootEvent = ReplicatedStorage.Guns.Events.Shoot

local reloading = false

local debounce = false
local aux = 1

local external
local TBS
local bullets
local Bullets
local Startbullets

local ERT
local NRT
local RD

local GunSound

local ReloadAnimation
local shoot
local Mode
local Equip
local shooting

local connection

function Knife(knife)
	print("potato")
end

function unbind()
	external = nil
	TBS = nil
	bullets = nil
	Bullets = nil
	Startbullets = nil

	ERT = nil
	NRT = nil
	RD = nil

	GunSound = nil

	ReloadAnimation = nil
	shoot = nil
	Mode = nil
	Equip = nil
	shooting = nil
end

function isequipped(gun)
	external = gun:WaitForChild("External")
	TBS = gun:GetAttribute("TBS")
	bullets = gun:GetAttribute("Bullets")
	Bullets = external:WaitForChild("Bullets")
	Startbullets = external:WaitForChild("StartingBullets")

	ERT = gun:GetAttribute("ERT")
	NRT = gun:GetAttribute("NRT")
	RD = gun:GetAttribute("RD")

	GunSound = external:WaitForChild("GunSound")

	ReloadAnimation = external:WaitForChild("Reload")
	shoot = external:WaitForChild("shoot")
	Mode = external:WaitForChild("Mode")
	Equip = external:WaitForChild("Equip")
	shooting = external:WaitForChild("shooting")

	local function shake()
		if not debounce then
			debounce = true
			for i=1,4 do 
				local a = math.random(-5,5)/100
				local b = math.random(-5,5)/100
				local c = math.random(-5,5)/100
				humanoid.CameraOffset = Vector3.new(a,b,c)
				wait(TBS/20)
			end
			debounce = false
		end
	end

	local function recoil()
		local numx = math.random(-1,1)
		if numx>0 then
			numx = math.clamp(numx,0.9,1)
		else
			numx = math.clamp(numx,-1,-0.9)
		end
		local numy = math.random(0.9,1)
		camera.CFrame = camera.CFrame:Lerp(camera.CFrame*CFrame.Angles(math.rad(numy),math.rad(numx),0),1/2)
	end

	local function reload()
		if Bullets.Value <(bullets+1) and reloading == false and Startbullets.Value>0 then
			reloading = true
			--reload2:FireServer(ReloadAnimation)
			gun:WaitForChild("GunGUI").Bullets.Text = "Reloading!"
			if (Startbullets.Value + Bullets.Value) > bullets then
				if Bullets.Value >0 then
					wait(NRT)
					Startbullets.Value = Startbullets.Value - (bullets - Bullets.Value) - 1
					Bullets.Value = bullets+1
					aux = 0
				else
					wait(ERT)
					Bullets.Value = bullets
					if aux == 0 then
						Startbullets.Value = Startbullets.Value - bullets - 1
					else
						Startbullets.Value = Startbullets.Value -bullets
					end
					aux = 1
				end
			elseif Startbullets.Value <= bullets and Startbullets.Value > 0 then
				if Bullets.Value > 0 then
					wait(NRT)
				else 
					wait(ERT)
				end
				Bullets.Value = Bullets.Value + Startbullets.Value
				Startbullets.Value = 0
			end
			gun:WaitForChild("GunGUI").Bullets.Text =Bullets.Value.."/"..bullets
			gun:WaitForChild("GunGUI").BulletsLeft.Text = Startbullets.Value
			EquipAnimation:FireServer(shoot)
			reloading = false
		end
	end

	local reloadMobileButton = ContextActionService:BindAction("ReloadBtn",reload,true,"r")
	ContextActionService:SetPosition("ReloadBtn",UDim2.new(0.72,0,0.20,0))
	ContextActionService:SetImage("ReloadBtn","http://www.roblox.com/asset/?id=10952419")

	local function IsShooting()
		if Bullets.Value <=0 or reloading == true then
			
		else
			local Head = game.Workspace[Player.Name].Head.CFrame.lookVector
			local mouse = CFrame.new(game.Workspace[Player.Name].Head.Position,mouse.Hit.p).lookVector
			local ray = Ray.new(gun.Handle.CFrame.p,(Player:GetMouse().Hit.p - gun.Handle.CFrame.p).unit*600)
			local part,position = game.Workspace:FindPartOnRayWithIgnoreList(ray,{Player.Character,gun,viewModel},false,true)
			GunSound:Play()
			local place = gun.Handle.CFrame.p
			local pos = gun.Handle.CFrame
			ShootEvent:FireServer(pos,0,1000,gun.Name)
			
			Bullets.Value = Bullets.Value - 1
			gun:WaitForChild("GunGUI").Bullets.Text =Bullets.Value.."/"..bullets
			wait()
			local numx = math.random(-1,1)
			if numx>0 then
				numx = math.clamp(numx,0.9,1)
			else
				numx = math.clamp(numx,-1,-0.9)
			end
			local numy = math.random(0.9,1)
			spawn(shake)
			local ok = 0
			for i=1,2,1 do
				if ok == 0 then
					RunService:BindToRenderStep("shake",1,recoil)
					ok=1
				end
				wait(RD/2)
			end
			ok=0
			local success, message = pcall(function() RunService:UnbindFromRenderStep("shake") end)
		end
	end

	EquipAnimation:FireServer(shoot)

	local ok1=1
	local ok2=1
	
	mouse.Button1Down:Connect(function()
		if ok1==1 and external ~= nil then
			shooting.Value = 1
			ok1=0
		end
		wait(TBS)
		ok1=1
	end)

	mouse.Button1Up:Connect(function()
		if	ok2==1 and external ~= nil then
			shooting.Value = 2
			ok2=0
		end
		wait(TBS)
		ok2=1
	end)
	
	local ok3=1
	
	connection = shooting.Changed:Connect(function()
		while external:FindFirstChild("shooting").Value == 1 and Bullets.Value>0 and ok3==1 do
			if Mode.Value == false and shooting.Value == 1 then
				ok3=0
				IsShooting()
				wait()
				shooting.Value = 2
				ok3=1
			else
				ok3=0
				IsShooting()
				wait()
				ok3=1
			end
		end
	end)
	
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.KeyCode == Enum.KeyCode.V then
			if Mode.Value == true then
				shooting.Value = 2
				Mode.Value = false
			elseif gun.Name ~= "ERG-1"then
				shooting.Value = 2
				Mode.Value = true
			end
		end
	end)
end

local function onInputBegan(input, process)
	if (process) then return; end
	if (input.UserInputType == Enum.UserInputType.MouseButton2) then
		crosshair.Visible = false
	end
end

local function onInputEnded(input, process)
	if (process) then return; end
	if (input.UserInputType == Enum.UserInputType.MouseButton2) then
		crosshair.Visible = true
	end
end

game:GetService("UserInputService").InputBegan:Connect(onInputBegan);
game:GetService("UserInputService").InputEnded:Connect(onInputEnded);
isequipped(Primary)

Headshot.OnClientEvent:Connect(function()
	hitmarker.Visible = true
	wait(0.2)
	hitmarker.Visible = false
end)

Bodyshot.OnClientEvent:Connect(function()
	hitmarker.Visible = true
	wait(0.2)
	hitmarker.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.Two  then
		connection:Disconnect()
		ContextActionService:UnbindAction("ReloadBtn")
		EquippedGun.Value = 2
	elseif input.KeyCode == Enum.KeyCode.One  then
		connection:Disconnect()
		ContextActionService:UnbindAction("ReloadBtn")
		EquippedGun.Value = 1
	elseif input.KeyCode == Enum.KeyCode.Three then
		connection:Disconnect()
		ContextActionService:UnbindAction("ReloadBtn")
		EquippedGun.Value = 3
	end
end)

mouse.WheelForward:Connect(function()
	if EquippedGun.Value > 1 then
		EquippedGun.Value = EquippedGun.Value - 1
	end
end)

mouse.WheelBackward:Connect(function()
	if EquippedGun.Value < 2 then
		EquippedGun.Value = EquippedGun.Value + 1
	end
end)

EquippedGun.Changed:Connect(function()
	if EquippedGun.Value == 1 then
		isequipped(Primary)
	elseif EquippedGun.Value ==2 then
		isequipped(Secondary)
	else
		unbind()
		Knife(Primary)
	end
end)

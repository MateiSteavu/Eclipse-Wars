local camera = game.Workspace.CurrentCamera;
local humanoid = game.Players.LocalPlayer.CharacterAdded:Wait():WaitForChild("Humanoid");
local player = game.Players.LocalPlayer
local spawned = player.PlayerGui:WaitForChild("spawned")
local chosenGun = player:WaitForChild("ChosenGun")
local chosenSec = player:WaitForChild("ChosenSec")
local EquippedGun = player:WaitForChild("PlayerGui").EquippedGun

local mouse = player:GetMouse()
local UserInputService = game:GetService("UserInputService")
 
local viewModel = game.ReplicatedStorage:WaitForChild("viewModel"):Clone();
viewModel.Name = "viewModel"

local function Disable(gun)
	local joint = Instance.new("Motor6D");
	joint.C0 = CFrame.new(2, 0, 0)*CFrame.fromEulerAnglesXYZ(-math.pi/2,0,0)
	joint.Part0 = viewModel.Head;
	joint.Part1 = gun.Handle;
	joint.Parent = viewModel.Head;
end

local function Unbind()
	while viewModel.Head:FindFirstChild("Motor6D") do
		viewModel.Head:FindFirstChild("Motor6D"):Destroy()
	end
end

local function onDied()
	viewModel.Parent = nil;
end

local function onUpdate(dt)
	viewModel.Head.CFrame = camera.CFrame;
end
 
humanoid.Died:Connect(onDied);
game:GetService("RunService").RenderStepped:Connect(onUpdate);

spawned.Changed:Connect(function()
	if spawned.Value == 1 then
		local repWeapon = game.ReplicatedStorage.Guns:WaitForChild(chosenGun.Value);
		local Primary = repWeapon:Clone()
		local repSec = game.ReplicatedStorage.Guns:WaitForChild(chosenSec.Value)
		local Secondary = repSec:Clone()
		viewModel.Parent = camera
		Primary.Parent = viewModel
		Secondary.Parent = viewModel
		
		local function ChangeGun(weapon, secweapon)
			Unbind()
			
			local joint = Instance.new("Motor6D");
			joint.C0 = CFrame.new(1, -.5, -4.25)
			joint.Part0 = viewModel.Head;
			joint.Part1 = weapon.Handle;
			joint.Parent = viewModel.Head;
			
			local joint1 = Instance.new("Motor6D");
			joint1.C0 = CFrame.new(2, 0, 0)*CFrame.fromEulerAnglesXYZ(-math.pi/2,0,0)
			joint1.Part0 = viewModel.Head;
			joint1.Part1 = secweapon.Handle;
			joint1.Parent = viewModel.Head;

			local aimCount = 0;
			local offset = weapon.Handle.CFrame:inverse() * weapon.Aim.CFrame;

			local function aimDownSights(aiming)
				local start = joint.C1;
				local goal = aiming and joint.C0 * offset or CFrame.new();

				aimCount = aimCount + 1;
				local current = aimCount;
				for t = 0, 101, 10 do
					if (current ~= aimCount) then break; end
					game:GetService("RunService").RenderStepped:Wait();
					joint.C1 = start:Lerp(goal, t/100);
				end
			end

			local function onInputBegan(input, process)
				if (process) then return; end
				if (input.UserInputType == Enum.UserInputType.MouseButton2) then
					aimDownSights(true);
				end
			end

			local function onInputEnded(input, process)
				if (process) then return; end
				if (input.UserInputType == Enum.UserInputType.MouseButton2) then
					aimDownSights(false);
				end
			end

			game:GetService("UserInputService").InputBegan:Connect(onInputBegan);
			game:GetService("UserInputService").InputEnded:Connect(onInputEnded);
		end
		
		ChangeGun(Primary,Secondary)
		
		UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if input.KeyCode == Enum.KeyCode.Two  then
				EquippedGun.Value = 2
			elseif input.KeyCode == Enum.KeyCode.One  then
				EquippedGun.Value = 1
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
				ChangeGun(Primary, Secondary)
			elseif EquippedGun.Value ==2 then
				ChangeGun(Secondary, Primary)
			else
				Unbind()
				Disable(Primary)
				Disable(Secondary)
			end
		end)
	end
end)

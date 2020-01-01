--[[
	Make sure to put in StarterCharacterScripts
	for best results!
--]]

--[[
Information: ↓
Title: RewindScript.Lua
Source: https://www.roblox.com/library/4563096422/cory-rewind-script
Source #2: https://github.com/ToxiPlays/scriptrepo/blob/master/RewindScript.lua
--]]

--init
print("Loading RewindScript...")

local rewinding = false
local cframelist = {}

function AddEvent(name)
	local nilnil = nil--such a surprise ...
	if game.ReplicatedStorage:FindFirstChild(name) then
		print(name,"already exists!")
		return game.ReplicatedStorage:FindFirstChild(name)
	end
	warn(name,"doesn't exist, creating...")
	local success, fail = pcall(function() 
		nilnil = Instance.new("RemoteEvent")
		nilnil.Name = name
		nilnil.Parent = game.ReplicatedStorage 
	end)
	if not success then
		print("Failed to load RewindScript ("..name.." failed: "..fail..")")
		assert(false,"shutdown...")
		return false
	end
	print("Successfully created",name)
	return nilnil
end

local event1 = AddEvent("StartRewind")
local event2 = AddEvent("StopRewind")

print("RewindScript by Toxi is successfully loaded!")

function AddCFrameList(obj)
	if rewinding then return end
	local insert = {}
	local iteration = 0
	local children = obj:GetChildren()
	for i=1,#children do
		if (children[i].ClassName == "Part") or (children[i].ClassName == "MeshPart") then
			
			iteration = iteration + 1
			insert[iteration] = {children[i].Name,children[i].CFrame}
			if obj.Humanoid.Health > 0 then
				insert["revive"] = true--for respawning if player rewinds while dead
			end
		end
	end
	cframelist[#cframelist+1] = insert
end

spawn(function()
	while wait() do
		if not rewinding then
			AddCFrameList(script.Parent)
		end
	end
end)

function stop()
	rewinding=false
	local cleanup = script.Parent:GetChildren()
	for i=1,#cleanup do
		pcall(function()
			cleanup[i].Anchored = false
		end)
	end
	warn("no rewind")
	script.Parent.Animate.Disabled = false
	game.Lighting.ColorCorrection.Enabled = false
end
event1.OnServerEvent:Connect(function()
	rewinding=true
	wait()
	warn("rewind")
	game.Lighting.ColorCorrection.Enabled = true
	script.Parent.Animate.Disabled = true
	for index=#cframelist,1,-1 do
		wait()
		if rewinding == false then return end
		local huh = cframelist[index]
		for i=1,#huh do
			local part = script.Parent:FindFirstChild(huh[1][1])
			if part then
				part.Anchored = true
				part.CFrame = huh[1][2]
			end
			if huh[1]["revive"] == true and script.Parent.Humanoid.Health == 0 then
				game.Players:GetPlayerFromCharacter(script.Parent):LoadCharacter()
			end
		end
		
		--after finishing
		cframelist[index] = nil
	end
	warn("rewind ran out of indices, stopping")
	stop()
end)
event2.OnServerEvent:Connect(stop)

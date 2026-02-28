-- ======================================================== --
--         🐝 CUSTOM BSS HUB | RED HIVE EDITION 🐝          --
-- ======================================================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ========================================== --
--             AUTO CLAIM HIVE                --
-- ========================================== --
local function ClaimAvailableHive()
    if not LocalPlayer:FindFirstChild("SpawnPos") or not LocalPlayer.SpawnPos.Value then
        local honeycombs = Workspace:FindFirstChild("Honeycombs")
        if honeycombs then
            for _, hive in pairs(honeycombs:GetChildren()) do
                if hive:FindFirstChild("Owner") and hive.Owner.Value == nil then
                    local pad = hive:FindFirstChild("ClaimPad") or hive:FindFirstChild("Platform")
                    local char = LocalPlayer.Character
                    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                    if pad and rootPart then
                        -- Teleport to the unowned hive pad and claim it
                        rootPart.CFrame = pad.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.5)
                        firetouchinterest(rootPart, pad, 0)
                        firetouchinterest(rootPart, pad, 1)
                        task.wait(1)
                        if LocalPlayer.SpawnPos.Value then break end
                    end
                end
            end
        end
    end
end
-- Run immediately upon execution
task.spawn(ClaimAvailableHive)

-- ========================================== --
--                MAIN WINDOW                 --
-- ========================================== --
local Window = Rayfield:CreateWindow({
   Name = "🐝 Nefoli_BSS Hub",
   LoadingTitle = "Loading Custom Features...",
   LoadingIcon = 10013087265,
   Theme = "Default",
})

local TabNormal = Window:CreateTab("🍯 Normal Farm", 4483362458)
local TabProgression = Window:CreateTab("📈 Progression", 4483362458)
local TabSafety = Window:CreateTab("🛡️ Safety", 4483362458)

-- ========================================== --
--             TWEENING SYSTEM                --
-- ========================================== --
local tweenSpeed = 60
local walkSpeed = 35
local activeTween = nil

local function TweenTo(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local distance = (rootPart.Position - targetPos).Magnitude
    local timeToTravel = distance / tweenSpeed
    
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    activeTween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
    activeTween:Play()
    
    return activeTween
end

local function CancelTween()
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end
end

-- ========================================== --
--            TAB 1: NORMAL FARM              --
-- ========================================== --
TabNormal:CreateSection("Auto Digging (Remote)")

local autoDigActive = false

TabNormal:CreateToggle({
   Name = "Auto Dig (Equips & Activates Tool)",
   CurrentValue = false,
   Flag = "AutoDig", 
   Callback = function(Value)
       autoDigActive = Value
       if autoDigActive then
           task.spawn(function()
               while autoDigActive do
                   local char = LocalPlayer.Character
                   if char then
                       local humanoid = char:FindFirstChild("Humanoid")
                       local tool = char:FindFirstChildOfClass("Tool")
                       
                       -- Force equip tool if it's sitting in the backpack
                       if not tool then
                           local backpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                           if backpackTool and humanoid then
                               humanoid:EquipTool(backpackTool)
                               tool = backpackTool
                           end
                       end
                       
                       -- Remotely trigger the tool
                       if tool then
                           tool:Activate()
                       end
                   end
                   task.wait(0.2)
               end
           end)
       end
   end,
})

TabNormal:CreateSection("Movement Settings")

TabNormal:CreateSlider({
   Name = "Tween Speed (Flying to Field)",
   Range = {30, 150}, Increment = 5, Suffix = "Speed", CurrentValue = 60, Flag = "TweenSpeedSlider",
   Callback = function(Value) tweenSpeed = Value end,
})

TabNormal:CreateSlider({
   Name = "Walk Speed (Farming inside Field)",
   Range = {16, 80}, Increment = 1, Suffix = "Speed", CurrentValue = 35, Flag = "WalkSpeedSlider",
   Callback = function(Value) walkSpeed = Value end,
})

TabNormal:CreateSection("Field Farming")

local normalFarmActive = false
local normalFarmLoop = nil
local selectedField = "Sunflower Field"
local bssFields = {"Sunflower Field", "Dandelion Field", "Mushroom Field", "Blue Flower Field", "Clover Field", "Spider Field", "Strawberry Field", "Bamboo Field", "Pine Tree Forest", "Rose Field", "Stump Field", "Cactus Field", "Pumpkin Patch", "Pineapple Patch", "Pepper Patch", "Coconut Field"}

TabNormal:CreateDropdown({
   Name = "Select Field",
   Options = bssFields,
   CurrentOption = {"Sunflower Field"},
   MultipleOptions = false,
   Flag = "FieldDropdown",
   Callback = function(Option) selectedField = Option[1] end,
})

TabNormal:CreateToggle({
   Name = "Enable Hybrid Farm (Tween to Field, Walk to Farm)",
   CurrentValue = false,
   Flag = "NormalFarm", 
   Callback = function(Value)
       normalFarmActive = Value
       if normalFarmActive then
           normalFarmLoop = task.spawn(function()
               while normalFarmActive do
                   local char = LocalPlayer.Character
                   local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                   local humanoid = char and char:FindFirstChild("Humanoid")
                   
                   if rootPart and humanoid then
                       -- Apply Custom WalkSpeed
                       humanoid.WalkSpeed = walkSpeed

                       -- Auto Collect Tokens in radius
                       local col = Workspace:FindFirstChild("Collectibles")
                       if col then
                           for _, token in pairs(col:GetChildren()) do
                               if (token:IsA("Part") or token:IsA("MeshPart")) and (token.Position - rootPart.Position).Magnitude <= 35 then
                                   firetouchinterest(rootPart, token, 0)
                                   firetouchinterest(rootPart, token, 1)
                               end
                           end
                       end

                       -- Movement Logic
                       local flowerZones = Workspace:FindFirstChild("FlowerZones")
                       if flowerZones then
                           local targetField = flowerZones:FindFirstChild(selectedField)
                           if targetField then
                               local distToField = (rootPart.Position - targetField.Position).Magnitude
                               
                               -- If far away, TWEEN (Fly) to the field
                               if distToField > 45 then
                                   local t = TweenTo(targetField.Position + Vector3.new(0, 5, 0))
                                   if t then t.Completed:Wait() end
                               else
                                   -- If inside the field, Cancel Tween and WALK
                                   CancelTween()
                                   if humanoid.MoveDirection.Magnitude == 0 then
                                       local rx = targetField.Position.X + math.random(-25, 25)
                                       local rz = targetField.Position.Z + math.random(-25, 25)
                                       humanoid:MoveTo(Vector3.new(rx, targetField.Position.Y, rz))
                                   end
                               end
                           end
                       end
                   end
                   task.wait(0.2)
               end
           end)
       else
           CancelTween()
           if normalFarmLoop then task.cancel(normalFarmLoop) end
           -- Reset walkspeed to normal when turning off
           local char = LocalPlayer.Character
           if char and char:FindFirstChild("Humanoid") then
               char.Humanoid.WalkSpeed = 16
           end
       end
   end,
})

-- ========================================== --
--         TAB 2: AUTO PROGRESSION            --
-- ========================================== --
TabProgression:CreateSection("Hive & Backpack Management")

local autoConvertActive = false
local autoConvertConnection = nil

TabProgression:CreateToggle({
   Name = "Auto Convert (Tween to Hive when full)",
   CurrentValue = false,
   Flag = "AutoConvert", 
   Callback = function(Value)
       autoConvertActive = Value
       if autoConvertActive then
           autoConvertConnection = task.spawn(function()
               while autoConvertActive do
                   task.wait(2)
                   if LocalPlayer:FindFirstChild("CoreStats") and LocalPlayer.CoreStats:FindFirstChild("Pollen") and LocalPlayer.CoreStats:FindFirstChild("Capacity") then
                       local currentPollen = LocalPlayer.CoreStats.Pollen.Value
                       local maxCapacity = LocalPlayer.CoreStats.Capacity.Value
                       
                       if currentPollen >= (maxCapacity * 0.95) then
                           local spawnPos = LocalPlayer:FindFirstChild("SpawnPos")
                           
                           if spawnPos and spawnPos.Value then
                               local wasFarming = normalFarmActive
                               
                               if wasFarming then normalFarmActive = false end
                               
                               -- Tween to the front of the hive
                               local t = TweenTo(spawnPos.Value.Position + Vector3.new(0, 0, 5))
                               if t then t.Completed:Wait() end
                               
                               -- Wait for backpack to empty out
                               task.wait(5) 
                               
                               if wasFarming then normalFarmActive = true end
                           end
                       end
                   end
               end
           end)
       else
           if autoConvertConnection then task.cancel(autoConvertConnection) end
       end
   end,
})

-- ========================================== --
--              TAB 3: SAFETY                 --
-- ========================================== --
TabSafety:CreateSection("Anti-Ban Features")

TabSafety:CreateButton({
   Name = "Load Anti-Mod Kicker",
   Callback = function()
       local dangerousPlayers = {"Onett", "Nabees", "Tito"}
       local function checkP(p)
           for _, n in pairs(dangerousPlayers) do if p.Name == n then LocalPlayer:Kick("Mod joined!") end end
           pcall(function() if p:GetRankInGroup(3982592) >= 200 then LocalPlayer:Kick("Admin joined!") end end)
       end
       for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then checkP(p) end end
       Players.PlayerAdded:Connect(checkP)
       Rayfield:Notify({Title = "Safety Loaded", Content = "You will be kicked if an admin joins.", Duration = 4})
   end,
})

Rayfield:LoadConfiguration()
-- ======================================================== --

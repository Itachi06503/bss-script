-- ======================================================== --
--         🐝 CUSTOM BSS HUB | RED HIVE EDITION 🐝          --
-- ======================================================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager") -- Switched to VIM for mobile
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
   Name = "🐝 Custom BSS Hub",
   LoadingTitle = "Loading Custom Features...",
   LoadingIcon = 10013087265,
   Theme = "Default",
})

-- ========================================== --
--                TABS SETUP                  --
-- ========================================== --
local TabNormal = Window:CreateTab("🍯 Normal Farm", 4483362458)
local TabProgression = Window:CreateTab("📈 Progression", 4483362458)
local TabBoost = Window:CreateTab("🔴 Boosting Mode", 4483362458)
local TabSafety = Window:CreateTab("🛡️ Safety", 4483362458)

-- ========================================== --
--             TWEENING SYSTEM                --
-- ========================================== --
local farmSpeed = 40
local activeTween = nil

local function TweenTo(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local distance = (rootPart.Position - targetPos).Magnitude
    local timeToTravel = distance / farmSpeed
    
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
TabNormal:CreateSection("Auto Digging")

local autoDigActive = false

TabNormal:CreateToggle({
   Name = "Auto Dig / Swing Tool",
   CurrentValue = false,
   Flag = "AutoDig", 
   Callback = function(Value)
       autoDigActive = Value
       if autoDigActive then
           task.spawn(function()
               while autoDigActive do
                   -- Simulates a raw left-click/tap in the center of the screen
                   VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                   task.wait(0.05)
                   VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                   task.wait(0.2) -- Adjust delay if it swings too fast/slow
               end
           end)
       end
   end,
})

TabNormal:CreateSection("Field Farming (Tween Movement)")

TabNormal:CreateSlider({
   Name = "Tween / Walk Speed",
   Range = {20, 100}, Increment = 1, Suffix = "Speed", CurrentValue = 40, Flag = "FarmSpeedSlider",
   Callback = function(Value) farmSpeed = Value end,
})

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
   Name = "Enable Normal Farm (Tween & Collect)",
   CurrentValue = false,
   Flag = "NormalFarm", 
   Callback = function(Value)
       normalFarmActive = Value
       if normalFarmActive then
           normalFarmLoop = task.spawn(function()
               while normalFarmActive do
                   local char = LocalPlayer.Character
                   local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                   
                   if rootPart then
                       -- 1. Auto Collect Tokens in radius
                       local col = Workspace:FindFirstChild("Collectibles")
                       if col then
                           for _, token in pairs(col:GetChildren()) do
                               if (token:IsA("Part") or token:IsA("MeshPart")) and (token.Position - rootPart.Position).Magnitude <= 35 then
                                   firetouchinterest(rootPart, token, 0)
                                   firetouchinterest(rootPart, token, 1)
                               end
                           end
                       end

                       -- 2. Tween Movement Logic
                       local flowerZones = Workspace:FindFirstChild("FlowerZones")
                       if flowerZones then
                           local targetField = flowerZones:FindFirstChild(selectedField)
                           if targetField then
                               local distToField = (rootPart.Position - targetField.Position).Magnitude
                               
                               -- If far away, tween to the center of the field
                               if distToField > 45 then
                                   local t = TweenTo(targetField.Position + Vector3.new(0, 3, 0))
                                   if t then t.Completed:Wait() end
                               else
                                   -- If already in the field, pick a random spot and tween there
                                   local rx = targetField.Position.X + math.random(-25, 25)
                                   local rz = targetField.Position.Z + math.random(-25, 25)
                                   local randomPos = Vector3.new(rx, targetField.Position.Y + 2, rz)
                                   
                                   local t = TweenTo(randomPos)
                                   if t then t.Completed:Wait() end
                               end
                           end
                       end
                   end
                   task.wait(0.1)
               end
           end)
       else
           CancelTween()
           if normalFarmLoop then task.cancel(normalFarmLoop) end
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
   Name = "Auto Convert (Return to Hive when full)",
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
                           local char = LocalPlayer.Character
                           local spawnPos = LocalPlayer:FindFirstChild("SpawnPos")
                           
                           if char and spawnPos and spawnPos.Value then
                               local wasFarming = normalFarmActive
                               
                               -- Disable normal farm temporarily
                               if wasFarming then 
                                   normalFarmActive = false 
                                   CancelTween()
                               end
                               
                               -- Tween to hive
                               local t = TweenTo(spawnPos.Value.Position)
                               if t then t.Completed:Wait() end
                               
                               task.wait(5) -- Wait for conversion
                               
                               -- Re-enable normal farm
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

TabProgression:CreateSection("World Interactables")

local autoToysActive = false
local autoToysConnection = nil

TabProgression:CreateToggle({
   Name = "Auto Wealth Clock & Free Dispensers",
   CurrentValue = false,
   Flag = "AutoToys", 
   Callback = function(Value)
       autoToysActive = Value
       if autoToysActive then
           autoToysConnection = task.spawn(function()
               while autoToysActive do
                   local char = LocalPlayer.Character
                   local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                   
                   if rootPart then
                       local targetToys = {"Wealth Clock", "Glue Dispenser", "Blueberry Dispenser", "Strawberry Dispenser", "Treat Dispenser"}
                       local toysFolder = Workspace:FindFirstChild("Toys")
                       
                       if toysFolder then
                           for _, toyName in pairs(targetToys) do
                               local toy = toysFolder:FindFirstChild(toyName)
                               if toy then
                                   local platform = toy:FindFirstChild("Platform") or toy:FindFirstChildWhichIsA("BasePart")
                                   if platform then
                                       firetouchinterest(rootPart, platform, 0)
                                       firetouchinterest(rootPart, platform, 1)
                                   end
                               end
                           end
                       end
                   end
                   task.wait(60)
               end
           end)
       else
           if autoToysConnection then task.cancel(autoToysConnection) end
       end
   end,
})

-- ========================================== --
--          TAB 3: RED HIVE BOOSTER           --
-- ========================================== --
TabBoost:CreateSection("Perfect Red Hive Boost")

local boostActive = false
local magnetRadius = 35
local boostConnection = nil

TabBoost:CreateToggle({
   Name = "🔴 Enable Red Hive Booster",
   CurrentValue = false,
   Flag = "RedBooster", 
   Callback = function(Value)
       boostActive = Value
       if boostActive then
           boostConnection = RunService.Heartbeat:Connect(function()
               local char = LocalPlayer.Character
               if not char then return end
               local rootPart = char:FindFirstChild("HumanoidRootPart")
               if not rootPart then return end

               local col = Workspace:FindFirstChild("Collectibles")
               if col then
                   for _, token in pairs(col:GetChildren()) do
                       if (token:IsA("Part") or token:IsA("MeshPart")) and (token.Position - rootPart.Position).Magnitude <= magnetRadius then
                           firetouchinterest(rootPart, token, 0); firetouchinterest(rootPart, token, 1)
                       end
                   end
               end

               local bestSpot, shortestDist = nil, math.huge
               for _, obj in pairs(Workspace:GetDescendants()) do
                   if obj.Name == "PreciseMark" or (obj:IsA("ParticleEmitter") and obj.Name == "Crosshair") then
                       local p = obj:IsA("BasePart") and obj or obj.Parent
                       if p and p:IsA("BasePart") then
                           local d = (p.Position - rootPart.Position).Magnitude
                           if d < 60 and d < shortestDist then shortestDist, bestSpot = d, p.Position end
                       end
                   end
               end

               if bestSpot then
                   -- Reusing TweenTo for boosting to precise marks
                   TweenTo(bestSpot)
               end
           end)
       else
           CancelTween()
           if boostConnection then boostConnection:Disconnect() end
       end
   end,
})

TabBoost:CreateSlider({
   Name = "Token Magnet Radius",
   Range = {10, 50}, Increment = 1, Suffix = "Studs", CurrentValue = 35, Flag = "MagnetSlider",
   Callback = function(Value) magnetRadius = Value end,
})

-- ========================================== --
--              TAB 4: SAFETY                 --
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

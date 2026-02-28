-- ======================================================== --
--           🐝 Nefoli_BSS | RED HIVE EDITION 🐝            --
-- ======================================================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ========================================== --
--                MAIN WINDOW                 --
-- ========================================== --
local Window = Rayfield:CreateWindow({
   Name = "🐝 Nefoli_BSS | Red Hive Edition",
   LoadingTitle = "Loading Nefoli_BSS...",
   LoadingIcon = 10013087265,
   Theme = "Default",
   KeySystem = false
})

local TabNormal = Window:CreateTab("🍯 Normal Farm", 4483362458)
local TabProgression = Window:CreateTab("📈 Progression", 4483362458)
local TabBoost = Window:CreateTab("🔴 Boosting Mode", 4483362458)
local TabSafety = Window:CreateTab("🛡️ Safety", 4483362458)

-- ========================================== --
--           TAB 1: NORMAL FARM               --
-- ========================================== --
TabNormal:CreateSection("Auto Digging")

local autoDigActive = false
local autoDigConnection = nil

TabNormal:CreateToggle({
   Name = "Auto Dig / Swing Tool",
   CurrentValue = false,
   Flag = "AutoDig", 
   Callback = function(Value)
       autoDigActive = Value
       if autoDigActive then
           autoDigConnection = RunService.RenderStepped:Connect(function()
               VirtualUser:ClickButton1(Vector2.new(0, 0))
           end)
       else
           if autoDigConnection then autoDigConnection:Disconnect() end
       end
   end,
})

TabNormal:CreateSection("Field Farming & Auto Collect")

local normalFarmActive = false
local normalFarmConnection = nil
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
   Name = "Enable Normal Farm (Wander & Collect)",
   CurrentValue = false,
   Flag = "NormalFarm", 
   Callback = function(Value)
       normalFarmActive = Value
       if normalFarmActive then
           normalFarmConnection = RunService.Heartbeat:Connect(function()
               local char = LocalPlayer.Character
               if not char then return end
               local rootPart, humanoid = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
               if not rootPart or not humanoid then return end

               local col = Workspace:FindFirstChild("Collectibles")
               if col then
                   for _, token in pairs(col:GetChildren()) do
                       if (token:IsA("Part") or token:IsA("MeshPart")) and (token.Position - rootPart.Position).Magnitude <= 35 then
                           firetouchinterest(rootPart, token, 0)
                           firetouchinterest(rootPart, token, 1)
                       end
                   end
               end

               local flowerZones = Workspace:FindFirstChild("FlowerZones")
               if flowerZones then
                   local targetField = flowerZones:FindFirstChild(selectedField)
                   if targetField then
                       if (rootPart.Position - targetField.Position).Magnitude > 45 then
                           humanoid:MoveTo(targetField.Position)
                       elseif humanoid.MoveDirection.Magnitude == 0 then
                           local rx = targetField.Position.X + math.random(-25, 25)
                           local rz = targetField.Position.Z + math.random(-25, 25)
                           humanoid:MoveTo(Vector3.new(rx, targetField.Position.Y, rz))
                       end
                   end
               end
           end)
       else
           if normalFarmConnection then normalFarmConnection:Disconnect() end
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
                       if LocalPlayer.CoreStats.Pollen.Value >= (LocalPlayer.CoreStats.Capacity.Value * 0.95) then
                           local char = LocalPlayer.Character
                           local humanoid = char and char:FindFirstChild("Humanoid")
                           local spawnPos = LocalPlayer:FindFirstChild("SpawnPos")
                           
                           if char and humanoid and spawnPos and spawnPos.Value then
                               local wasFarming = normalFarmActive
                               normalFarmActive = false 
                               humanoid:MoveTo(spawnPos.Value.Position)
                               task.wait(5) 
                               normalFarmActive = wasFarming
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
               local rootPart, humanoid = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
               if not rootPart or not humanoid then return end

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
                   if (Vector3.new(bestSpot.X, rootPart.Position.Y, bestSpot.Z) - rootPart.Position).Magnitude < 3 then
                       humanoid:MoveTo(rootPart.Position) 
                   else
                       humanoid:MoveTo(bestSpot) 
                   end
               end
           end)
       else
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
   Name = "Load Anti-Mod Kicker (Runs in background)",
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

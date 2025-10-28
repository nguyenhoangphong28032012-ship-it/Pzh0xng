-- 🎮 EVADE AUTO FARM SCRIPT
-- 🤖 Created for GitHub
-- ⚡ Auto Collect Orbs, Auto Avoid Obstacles

local EvadeAutoFarm = {
    Enabled = false,
    AutoCollect = true,
    AutoAvoid = true,
    Stats = {Orbs = 0, Time = 0, StartTime = 0}
}

-- 🔧 Cấu hình
local CONFIG = {
    COLLECT_RANGE = 20,
    AVOID_RAYCAST_DISTANCE = 15,
    JUMP_CHANCE = 5, -- 5% cơ hội nhảy mỗi frame
    WALKSPEED = 25
}

function EvadeAutoFarm:Init()
    self:SecurityCheck()
    self:CreateGUI()
    self:StartMainLoop()
    self:ShowNotification("EVADE AUTO FARM", "Đã khởi động! ✅")
end

function EvadeAutoFarm:SecurityCheck()
    -- Kiểm tra game
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    if not string.find(string.lower(gameName), "evade") then
        warn("⚠️ Script được thiết kế cho game Evade!")
    end
    print("🎮 Game: " .. gameName)
end

function EvadeAutoFarm:CreateGUI()
    local player = game:GetService("Players").LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "EvadeAutoFarmGUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 220)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "EVADE AUTO FARM 🤖"
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Parent = mainFrame
    
    -- Toggle Button
    self.toggleBtn = Instance.new("TextButton")
    self.toggleBtn.Text = "🚀 BẬT AUTO FARM"
    self.toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
    self.toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    self.toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    self.toggleBtn.TextColor3 = Color3.white
    self.toggleBtn.Parent = mainFrame
    
    self.toggleBtn.MouseButton1Click:Connect(function()
        self:ToggleFarm()
    end)
    
    -- Status
    self.statusLabel = Instance.new("TextLabel")
    self.statusLabel.Text = "Status: OFF"
    self.statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
    self.statusLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
    self.statusLabel.BackgroundTransparency = 1
    self.statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    self.statusLabel.Parent = mainFrame
    
    -- Stats
    self.statsLabel = Instance.new("TextLabel")
    self.statsLabel.Text = "Orbs: 0 | Time: 0s"
    self.statsLabel.Size = UDim2.new(0.9, 0, 0, 25)
    self.statsLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
    self.statsLabel.BackgroundTransparency = 1
    self.statsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    self.statsLabel.Parent = mainFrame
    
    -- Features Toggle
    self.featuresLabel = Instance.new("TextLabel")
    self.featuresLabel.Text = "Auto Collect: ✅ | Auto Avoid: ✅"
    self.featuresLabel.Size = UDim2.new(0.9, 0, 0, 20)
    self.featuresLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
    self.featuresLabel.BackgroundTransparency = 1
    self.featuresLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.featuresLabel.TextScaled = true
    self.featuresLabel.Parent = mainFrame
    
    -- Hotkey Info
    local hotkeyLabel = Instance.new("TextLabel")
    hotkeyLabel.Text = "Hotkey: F (Toggle) | R (Features)"
    hotkeyLabel.Size = UDim2.new(0.9, 0, 0, 15)
    hotkeyLabel.Position = UDim2.new(0.05, 0, 0.9, 0)
    hotkeyLabel.BackgroundTransparency = 1
    hotkeyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    hotkeyLabel.TextScaled = true
    hotkeyLabel.Parent = mainFrame
end

function EvadeAutoFarm:ToggleFarm()
    self.Enabled = not self.Enabled
    
    if self.Enabled then
        self.toggleBtn.Text = "🛑 TẮT AUTO FARM"
        self.toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        self.statusLabel.Text = "Status: ĐANG FARMING..."
        self.statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        self.Stats.StartTime = os.time()
        self:ApplyWalkSpeed()
    else
        self.toggleBtn.Text = "🚀 BẬT AUTO FARM"
        self.toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        self.statusLabel.Text = "Status: OFF"
        self.statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        self:ResetWalkSpeed()
    end
end

function EvadeAutoFarm:ApplyWalkSpeed()
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = CONFIG.WALKSPEED
    end
end

function EvadeAutoFarm:ResetWalkSpeed()
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = 16 -- Default speed
    end
end

function EvadeAutoFarm:StartMainLoop()
    game:GetService("RunService").Heartbeat:Connect(function()
        if self.Enabled then
            self:AutoFarmLogic()
            self:UpdateStats()
        end
    end)
end

function EvadeAutoFarm:AutoFarmLogic()
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        -- Auto Collect Orbs
        if self.AutoCollect then
            self:CollectNearbyOrbs(rootPart)
        end
        
        -- Auto Avoid Obstacles
        if self.AutoAvoid then
            self:AvoidObstacles(character)
        end
        
        -- Anti-AFK
        self:AntiAFK(character)
    end
end

function EvadeAutoFarm:CollectNearbyOrbs(rootPart)
    -- Tìm tất cả objects có thể là orbs
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Part") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "orb") or string.find(nameLower, "coin") or string.find(nameLower, "collect") then
                local distance = (rootPart.Position - obj.Position).Magnitude
                
                if distance < CONFIG.COLLECT_RANGE then
                    -- Di chuyển đến orb
                    rootPart.CFrame = CFrame.new(obj.Position)
                    
                    -- Tăng số lượng orbs
                    self.Stats.Orbs = self.Stats.Orbs + 1
                    break
                end
            end
        end
    end
end

function EvadeAutoFarm:AvoidObstacles(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Raycast để phát hiện vật cản phía trước
    local rayOrigin = rootPart.Position
    local rayDirection = rootPart.CFrame.LookVector * CONFIG.AVOID_RAYCAST_DISTANCE
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if raycastResult then
        -- Nhảy để tránh vật cản
        character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        
        -- Di chuyển ngẫu nhiên trái/phải
        local randomDirection = math.random(1, 2) == 1 and -1 or 1
        local newPosition = rootPart.Position + Vector3.new(randomDirection * 8, 0, 0)
        rootPart.CFrame = CFrame.new(newPosition)
    end
end

function EvadeAutoFarm:AntiAFK(character)
    -- Chống AFK bằng cách di chuyển nhẹ
    if math.random(1, 100) <= CONFIG.JUMP_CHANCE then
        character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

function EvadeAutoFarm:UpdateStats()
    if self.Stats.StartTime > 0 then
        self.Stats.Time = os.time() - self.Stats.StartTime
        self.statsLabel.Text = string.format("Orbs: %d | Time: %ds", self.Stats.Orbs, self.Stats.Time)
    end
    
    -- Update features status
    local collectStatus = self.AutoCollect and "✅" or "❌"
    local avoidStatus = self.AutoAvoid and "✅" or "❌"
    self.featuresLabel.Text = string.format("Auto Collect: %s | Auto Avoid: %s", collectStatus, avoidStatus)
end

function EvadeAutoFarm:ToggleFeatures()
    self.AutoCollect = not self.AutoCollect
    self.AutoAvoid = not self.AutoAvoid
    self:ShowNotification("FEATURES", string.format("Collect: %s | Avoid: %s", 
        self.AutoCollect and "ON" or "OFF", 
        self.AutoAvoid and "ON" or "OFF"))
end

function EvadeAutoFarm:SetupHotkeys()
    local UIS = game:GetService("UserInputService")
    
    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F then
            self:ToggleFarm()
        elseif input.KeyCode == Enum.KeyCode.R then
            self:ToggleFeatures()
        end
    end)
end

function EvadeAutoFarm:ShowNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = title,
        Text = text,
        Duration = 5
    })
end

-- Khởi động script
EvadeAutoFarm:SetupHotkeys()
EvadeAutoFarm:Init()

print("🎮 Evade Auto Farm đã sẵn sàng!")
print("🎯 Hotkeys: F (Toggle Farm) | R (Toggle Features)")
print("🤖 Features: Auto Collect Orbs, Auto Avoid Obstacles")

-- TurboHub Roxo - Ball Flight Assist 1.044
-- OWN-GAME / ROBLOX STUDIO SERVER SCRIPT ONLY.
--
-- Setup:
-- 1) Put this Script in ServerScriptService in your own Roblox experience.
-- 2) Make sure the ball is a BasePart named "Ball" somewhere under Workspace.
-- 3) Put a VehicleSeat in each vehicle.
-- 4) Set the VehicleSeat attribute "BallFlightEnabled" to true to enable.
-- 5) Set it to false to return to normal vehicle physics.
--
-- This does not hide scripts, spoof game state, bypass anti-cheat, or work
-- as an executor script in someone else's game.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
    warn("[Ball Flight Assist 1.044] Studio-only script; stopping.")
    return
end

local BALL_NAME = "Ball"
local CRUISE_SPEED = 95       -- studs/second
local RESPONSE = 2.2           -- how quickly velocity changes
local MAX_ACCELERATION = 150   -- studs/second^2
local HOVER_DISTANCE = 12      -- stop accelerating closer than this
local UPDATE_EVERY = 0.05

local activeForces = {}
local elapsed = 0

local function findBall()
    local ball = workspace:FindFirstChild(BALL_NAME, true)
    if ball and ball:IsA("BasePart") then
        return ball
    end
    return nil
end

local function removeForce(seat)
    local data = activeForces[seat]
    if not data then return end

    if data.force then data.force:Destroy() end
    if data.attachment then data.attachment:Destroy() end
    activeForces[seat] = nil
end

local function getOrCreateForce(seat, root)
    local current = activeForces[seat]
    if current and current.root == root and current.force.Parent then
        return current
    end

    removeForce(seat)

    local attachment = Instance.new("Attachment")
    attachment.Name = "BallFlightAttachment_1044"
    attachment.Parent = root

    local force = Instance.new("VectorForce")
    force.Name = "BallFlightForce_1044"
    force.Attachment0 = attachment
    force.RelativeTo = Enum.ActuatorRelativeTo.World
    force.ApplyAtCenterOfMass = true
    force.Parent = root

    local data = {
        root = root,
        attachment = attachment,
        force = force,
    }
    activeForces[seat] = data
    return data
end

local function updateSeat(seat, ball)
    if not seat:IsA("VehicleSeat") then return end
    if seat:GetAttribute("BallFlightEnabled") ~= true then
        removeForce(seat)
        return
    end

    local humanoid = seat.Occupant
    if not humanoid then
        removeForce(seat)
        return
    end

    local player = Players:GetPlayerFromCharacter(humanoid.Parent)
    if not player or not ball then
        removeForce(seat)
        return
    end

    local root = seat.AssemblyRootPart
    if not root then
        removeForce(seat)
        return
    end

    local data = getOrCreateForce(seat, root)
    local offset = ball.Position - root.Position
    local distance = offset.Magnitude

    local desiredVelocity = Vector3.zero
    if distance > HOVER_DISTANCE then
        desiredVelocity = offset.Unit * CRUISE_SPEED
    end

    local velocityError = desiredVelocity - root.AssemblyLinearVelocity
    local acceleration = velocityError * RESPONSE

    if acceleration.Magnitude > MAX_ACCELERATION then
        acceleration = acceleration.Unit * MAX_ACCELERATION
    end

    -- Counter gravity so the vehicle can hover, then add controlled movement.
    local totalAcceleration = Vector3.new(0, workspace.Gravity, 0) + acceleration
    data.force.Force = totalAcceleration * root.AssemblyMass
end

RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < UPDATE_EVERY then return end
    elapsed = 0

    local ball = findBall()
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("VehicleSeat") then
            updateSeat(object, ball)
        end
    end

    for seat in pairs(activeForces) do
        if not seat.Parent then
            removeForce(seat)
        end
    end
end)

print("[Ball Flight Assist 1.044] Loaded. Enable with VehicleSeat attribute BallFlightEnabled = true.")

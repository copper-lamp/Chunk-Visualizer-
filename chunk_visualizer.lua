-- chunk_visualizer.lua for LeviLamina
-- 区块显示插件 for Minecraft BE

local LeviLamina = require("LeviLamina")
local Color = require("LeviLamina.Color")
local Vector3 = require("LeviLamina.Vector3")

-- 配置参数
local config = {
    particleType = "minecraft:endrod_particle",
    defaultRange = 1,
    particleLifetime = 30,
    updateInterval = 20, -- 更新间隔(ticks)
    heightOffset = 1    -- 粒子高度偏移(相对于玩家脚部)
}

-- 存储玩家数据
local playerData = {}

-- 初始化函数
function Initialize()
    -- 注册命令
    LeviLamina.Command.register({
        name = "chunkview",
        description = "切换区块边界显示",
        permission = "member",
        overloads = {
            {
                parameters = {},
                handler = ToggleChunkView
            },
            {
                parameters = {
                    { name = "range", type = "int", optional = true }
                },
                handler = SetChunkViewRange
            }
        }
    })
    
    -- 注册事件监听
    LeviLamina.Event.listen("player_join", OnPlayerJoin)
    LeviLamina.Event.listen("player_left", OnPlayerLeft)
    LeviLamina.Event.listen("tick", OnTick)
    
    LeviLamina.Logger.info("区块显示插件已加载!")
end

-- 玩家加入事件
function OnPlayerJoin(event)
    local player = event.player
    playerData[player.xuid] = {
        enabled = false,
        range = config.defaultRange,
        lastChunkPos = nil,
        markers = {}
    }
    player:sendMessage("§a使用 /chunkview 命令显示区块边界")
end

-- 玩家离开事件
function OnPlayerLeave(event)
    playerData[event.player.xuid] = nil
end

-- 游戏刻事件（用于更新显示）
function OnTick(event)
    for xuid, data in pairs(playerData) do
        if data.enabled then
            local player = LeviLamina.Player.getByXuid(xuid)
            if player then
                UpdateChunkDisplay(player, data)
            end
        end
    end
end

-- 切换区块显示
function ToggleChunkView(command)
    local player = command.player
    local data = playerData[player.xuid]
    
    data.enabled = not data.enabled
    if data.enabled then
        player:sendMessage("§a区块显示已开启 (范围: "..data.range..")")
        UpdateChunkDisplay(player, data)
    else
        ClearChunkMarkers(player, data)
        player:sendMessage("§c区块显示已关闭")
    end
end

-- 设置显示范围
function SetChunkViewRange(command)
    local player = command.player
    local range = command.parameters.range or config.defaultRange
    local data = playerData[player.xuid]
    
    if range < 0 or range > 5 then
        player:sendMessage("§e范围必须在0-5之间")
        return
    end
    
    data.range = range
    player:sendMessage("§a区块显示范围设置为 "..range)
    
    if data.enabled then
        UpdateChunkDisplay(player, data)
    end
end

-- 更新区块显示
function UpdateChunkDisplay(player, data)
    local pos = player.position
    local currentChunk = {
        x = math.floor(pos.x / 16),
        z = math.floor(pos.z / 16)
    }
    
    -- 如果玩家仍在同一区块组，则不更新
    if data.lastChunkPos and 
       math.abs(data.lastChunkPos.x - currentChunk.x) <= data.range and
       math.abs(data.lastChunkPos.z - currentChunk.z) <= data.range then
        return
    end
    
    data.lastChunkPos = currentChunk
    ClearChunkMarkers(player, data)
    
    -- 绘制新的区块边界
    local playerY = math.floor(pos.y) + config.heightOffset
    for x = currentChunk.x - data.range, currentChunk.x + data.range do
        for z = currentChunk.z - data.range, currentChunk.z + data.range do
            DrawChunkBoundary(x, z, playerY, player, data)
        end
    end
end

-- 绘制单个区块边界
function DrawChunkBoundary(chunkX, chunkZ, y, player, data)
    local startX = chunkX * 16
    local startZ = chunkZ * 16
    local color = GetChunkColor(chunkX, chunkZ)
    
    -- 存储创建的粒子标记
    local markers = {}
    
    -- 绘制四条边
    for i = 0, 16 do
        -- 南北边界
        local northParticle = player:spawnParticle(
            config.particleType,
            Vector3.new(startX + i, y, startZ),
            color,
            config.particleLifetime
        )
        table.insert(markers, northParticle)
        
        local southParticle = player:spawnParticle(
            config.particleType,
            Vector3.new(startX + i, y, startZ + 16),
            color,
            config.particleLifetime
        )
        table.insert(markers, southParticle)
        
        -- 东西边界
        local westParticle = player:spawnParticle(
            config.particleType,
            Vector3.new(startX, y, startZ + i),
            color,
            config.particleLifetime
        )
        table.insert(markers, westParticle)
        
        local eastParticle = player:spawnParticle(
            config.particleType,
            Vector3.new(startX + 16, y, startZ + i),
            color,
            config.particleLifetime
        )
        table.insert(markers, eastParticle)
    end
    
    -- 保存标记以便后续清除
    table.insert(data.markers, markers)
end

-- 清除区块标记
function ClearChunkMarkers(player, data)
    for _, markers in ipairs(data.markers) do
        for _, marker in ipairs(markers) do
            marker:destroy()
        end
    end
    data.markers = {}
end

-- 获取区块颜色（基于坐标）
function GetChunkColor(chunkX, chunkZ)
    -- 使用HSV颜色空间生成鲜艳的颜色
    local hue = (chunkX * 31 + chunkZ * 7) % 360
    return Color.fromHSV(hue / 360, 0.8, 0.9)
end

-- 初始化插件
Initialize()
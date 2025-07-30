# Chunk Visualizer 区块显示插件

一个轻量级的Minecraft Bedrock Edition插件，使用粒子效果可视化显示区块边界，帮助玩家和开发者更好地理解游戏世界结构。

### 功能特性

- **区块边界可视化**：使用彩色粒子标记区块边界
- **动态更新**：当玩家移动跨越区块时自动更新显示
- **可调范围**：支持1-5个区块半径的显示范围
- **低性能开销**：优化实现减少对游戏性能的影响
- **多玩家支持**：每个玩家可以独立控制自己的显示

### 安装要求

- Minecraft Bedrock Dedicated Server (BDS) 1.21.9
- [LeviLamina](https://github.com/LiteLDev/LeviLamina) 模组加载器

### 安装方法

1. 确保已正确安装LeviLamina
2. 将`chunk_visualizer.lua`文件放入服务器的`plugins`文件夹
3. 启动或重启服务器

### 使用说明

**基本命令**:
```
/function border
```

**示例**:
- `/chunkview` - 开启/关闭区块显示
- `/chunkview 2` - 设置显示范围为2（显示5x5区块区域）

### 配置选项

可以通过修改插件文件开头的`config`表来自定义插件行为：

```lua
local config = {
    particleType = "minecraft:endrod_particle", -- 使用的粒子类型
    defaultRange = 1,                          -- 默认显示范围
    particleLifetime = 30,                     -- 粒子持续时间(tick)
    updateInterval = 20,                       -- 更新间隔(tick)
    heightOffset = 1                           -- 粒子高度偏移
}
```

### 已知问题

1. 在极高或极低Y坐标时，粒子可能不可见
2. 大量粒子同时显示可能影响客户端性能
3. 某些粒子类型在不同设备上显示效果可能有差异

### 贡献指南

欢迎提交Pull Request或Issue报告问题。贡献时请遵循以下规范：

1. 使用清晰的提交信息
2. 保持代码风格一致
3. 为新功能添加适当的测试
4. 更新文档反映变更

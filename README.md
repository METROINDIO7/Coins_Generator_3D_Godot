# Coins Generator 3D Plugin Documentation

## Demo 🎥
![Demo](addons/Coins_Generator/tuto.gif)




## Overview
Coins Generator 3D is a Godot 4.3 plugin that allows users to easily generate collectible coins along Path3D nodes. The plugin provides flexible placement options and an intuitive UI for managing coin distribution.

## Installation
1. Copy the `Coins_Generator` folder to your `res://addons/` directory.
2. Enable the plugin in **Project Settings** > **Plugins**.
3. You will now see the `CoinSpawner` node available in the scene tree.

## Features
- Custom `CoinSpawner` node for generating coins.
- Support for direct placement or PathFollow3D-based placement.
- Automatic coin distribution based on path length or equal distribution.
- Easy-to-use UI with a "Generate Coins" button.
- Configuration warnings for missing paths.

## How to Use
1. Add a `CoinSpawner` node to your scene.
2. Assign a coin scene (`coin_scene`) to spawn.
3. Add `Path3D` child nodes under `CoinSpawner` to define paths.
4. Configure settings:
   - **Total Coins**: Number of coins to generate.
   - **Use Direct Placement**: Toggle between direct placement and PathFollow3D.
   - **Distribute by Length**: Adjust coin distribution based on path length.
5. Press the **Generate Coins** button in the Inspector to spawn coins.

## Settings
### Basic Options
- **Coin Scene**: PackedScene of the coin object.
- **Total Coins**: Number of coins to generate.

### Advanced Options
- **Use Direct Placement**: Place coins directly along paths.
- **Distribute by Length**: Spread coins proportionally based on path length.

### Generation Controls
- **Generate Coins Button**: Creates coins according to the specified parameters.

## Code Breakdown
### `Coins_Generator.gd`
This script registers the `CoinSpawner` as a custom node in Godot's editor and adds a tool menu entry to create it easily.

### `coin_spawner.gd`
The core script of the plugin, handling coin generation and placement based on user settings.

## Notes
- If no `Path3D` nodes are present under `CoinSpawner`, a warning will appear.
- The plugin only runs in the editor and does not affect runtime behavior.

## License
This plugin is open-source and free to use in any project. Contributions and improvements are welcome!




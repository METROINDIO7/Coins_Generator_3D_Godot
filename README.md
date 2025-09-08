# Coins Generator 3D Plugin Documentation

## Demo 🎥
![Demo](addons/Coins_Generator/tuto.gif)


A powerful and flexible plugin for Godot 4 that allows you to procedurally generate objects along Path3D nodes. Perfect for creating "only up" style games, platformers, and any project requiring systematic object placement.

## Features

### Multi-Object Support
- **Object Scenes**: Support for multiple PackedScene objects, not just coins
- **Folder Loading**: Automatically load all .tscn files from a specified folder
- **Random Selection**: Objects can be selected randomly or in sequence
- **Weight System**: Assign different spawn probabilities to different objects

### Advanced Placement Options
- **Spacing Modes**: 
  - Uniform: Equal spacing between objects
  - Random: Randomized spacing within specified ranges
  - Grouped: Cluster objects in groups along the path
- **Direct Placement**: Place objects directly along paths
- **Length Distribution**: Spread objects proportionally based on path length

### Customization Features
- **Rotation Variance**: Add random rotation to spawned objects
- **Scale Variation**: Randomize object scales within specified ranges
- **Offset Controls**: Fine-tune object positioning relative to paths
- **Preview Mode**: Visualize placement before final generation

### Generation Controls
- **Generate Button**: One-click generation with current settings
- **Clear Objects**: Remove all generated objects
- **Batch Operations**: Generate across multiple Path3D nodes simultaneously

## Settings Overview

### Basic Options
- **Object Scenes**: Array of PackedScene objects to spawn
- **Folder Path**: Optional folder path to auto-load scenes
- **Total Objects**: Number of objects to generate
- **Selection Mode**: Random, Sequential, or Weighted selection

### Advanced Options
- **Spacing Mode**: Choose between Uniform, Random, or Grouped
- **Min/Max Spacing**: Control spacing ranges for random mode
- **Rotation Range**: Set random rotation limits (degrees)
- **Scale Variance**: Define scale randomization range
- **Use Direct Placement**: Place objects directly along paths
- **Distribute by Length**: Spread objects proportionally based on path length

### Generation Controls
- **Generate Objects Button**: Creates objects according to specified parameters
- **Clear Generated Button**: Removes all previously generated objects
- **Preview Toggle**: Show/hide placement preview

## Code Structure

### `plugin.gd`
Registers the `CoinSpawner` as a custom node in Godot's editor and adds tool menu entries.

### `Coin_spawner.gd`
The core script handling object generation, placement algorithms, and user interface integration.

### `Coin_spawner.tscn`
The node scene with all UI controls and inspector properties properly configured.

## Usage Instructions

1. **Add CoinSpawner Node**: Create an ObjectSpawner node in your scene
2. **Add Path3D Children**: Add one or more Path3D nodes as children
3. **Configure Objects**: Set up your object scenes or folder path
4. **Adjust Settings**: Configure spacing, rotation, and scale options
5. **Generate**: Click the "Generate Objects" button to create your objects

## Perfect For

- **Only Up Games**: Generate platforms, obstacles, and collectibles
- **Endless Runners**: Create procedural level elements
- **Platformers**: Place coins, power-ups, and interactive objects
- **Racing Games**: Add checkpoints, boosts, and track elements
- **Adventure Games**: Scatter collectibles and environmental objects

## Notes

- If no `Path3D` nodes are present under `CoinSpawner`, a warning will appear
- The plugin only runs in the editor and does not affect runtime behavior
- Generated objects are automatically organized in the scene tree
- All settings are saved with the scene for easy iteration

## Requirements

- Godot 4.0 or later
- Path3D nodes for object placement
- PackedScene resources for objects to spawn

## License

This plugin is open-source and free to use in any project. Contributions and improvements are welcome!

## Version History

- **v2.0**: Multi-object support, folder loading, advanced placement modes
- **v1.0**: Basic coin generation along paths





@tool
extends Node3D

@export_group("Coin to Spawn")
@export var object_scenes: Array[PackedScene] = []
@export var objects_folder_path: String = "":
	set(value):
		objects_folder_path = value
		_load_objects_from_folder()

@export_group("Generation Settings")
@export var total_objects: int = 10
@export var random_object_selection: bool = true
@export var object_spacing_mode: SpacingMode = SpacingMode.EVEN

@export_group("Advanced Options")
@export var use_direct_placement: bool = true
@export var distribute_by_length: bool = false
@export var add_random_rotation: bool = false
@export var random_scale_variation: float = 0.0

@export_group("Generation Control")
@export var generate: bool = false:
	set(value):
		generate = false
		generate_objects()

enum SpacingMode {
	EVEN,
	RANDOM,
	CLUSTERED
}

var _last_children_count: int = 0
var _loaded_scenes: Array[PackedScene] = []

func _ready() -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()
		_load_objects_from_folder()

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	
	var current_children_count = get_path_children().size()
	if current_children_count != _last_children_count:
		_last_children_count = current_children_count
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if get_path_children().size() == 0:
		warnings.append("No Path3D nodes found. Add Path3D nodes as children to generate objects.")
	
	if object_scenes.is_empty() and _loaded_scenes.is_empty():
		warnings.append("No object scenes assigned. Add scenes to 'Object Scenes' or set 'Objects Folder Path'.")
	
	return warnings

func _load_objects_from_folder() -> void:
	_loaded_scenes.clear()
	
	if objects_folder_path.is_empty():
		return
	
	var dir = DirAccess.open(objects_folder_path)
	if dir == null:
		print("Error: Cannot access folder: ", objects_folder_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tscn"):
			var full_path = objects_folder_path + "/" + file_name
			var scene = load(full_path) as PackedScene
			if scene:
				_loaded_scenes.append(scene)
				print("Loaded scene: ", full_path)
		file_name = dir.get_next()
	
	print("Loaded ", _loaded_scenes.size(), " scenes from folder")

func generate_objects() -> void:
	var available_scenes = _get_available_scenes()
	
	if available_scenes.is_empty():
		print("Error: No object scenes available for generation")
		return
	
	clear_objects()
	
	var paths = get_path_children()
	if paths.size() == 0:
		print("Warning: No Path3D nodes found as children of CoinSpawner")
		return
	
	if total_objects <= 0:
		return
	
	# Calculate object distribution among paths
	var objects_per_path = calculate_object_distribution(paths)
	
	# Distribute objects in each Path3D according to calculated distribution
	for i in range(paths.size()):
		var path = paths[i]
		var objects_for_this_path = objects_per_path[i]
		
		if use_direct_placement:
			generate_objects_direct(path, objects_for_this_path, available_scenes)
		else:
			generate_objects_with_pathfollow(path, objects_for_this_path, available_scenes)

func _get_available_scenes() -> Array[PackedScene]:
	var all_scenes: Array[PackedScene] = []
	
	# Add manually assigned scenes
	for scene in object_scenes:
		if scene != null:
			all_scenes.append(scene)
	
	# Add scenes loaded from folder
	for scene in _loaded_scenes:
		all_scenes.append(scene)
	
	return all_scenes

# Get all children that are Path3D
func get_path_children() -> Array:
	var paths = []
	for child in get_children():
		if child is Path3D:
			paths.append(child)
	return paths

# Calculate how many objects each path should have
func calculate_object_distribution(paths: Array) -> Array:
	var result = []
	var num_paths = paths.size()
	
	if distribute_by_length:
		# Distribute based on relative length of each path
		var total_length = 0.0
		var lengths = []
		
		# Calculate total length and individual length
		for path in paths:
			var length = path.curve.get_baked_length()
			total_length += length
			lengths.append(length)
		
		# Calculate objects for each path based on its length proportion
		for i in range(num_paths):
			var proportion = lengths[i] / total_length if total_length > 0 else 0
			var objects = int(round(proportion * total_objects))
			result.append(objects)
		
		# Adjust to ensure total is correct
		var current_total = result.reduce(func(accum, objects): return accum + objects, 0)
		while current_total != total_objects:
			if current_total < total_objects:
				var max_length_idx = lengths.find(lengths.max())
				result[max_length_idx] += 1
			else:
				var min_length_idx = lengths.find(lengths.min())
				if result[min_length_idx] > 0:
					result[min_length_idx] -= 1
				else:
					var idx_with_objects = result.find(result.max())
					result[idx_with_objects] -= 1
			
			current_total = result.reduce(func(accum, objects): return accum + objects, 0)
	else:
		# Simple equitable distribution
		var base_count = total_objects / num_paths
		var remainder = total_objects % num_paths
		
		for i in range(num_paths):
			result.append(base_count + (1 if i < remainder else 0))
	
	return result

func generate_objects_with_pathfollow(path: Path3D, object_count: int, available_scenes: Array[PackedScene]) -> void:
	var path_length = path.curve.get_baked_length()
	if path_length <= 0 or object_count <= 0 or available_scenes.is_empty():
		return
	
	var positions = _calculate_positions(object_count, path_length)
	
	for i in range(object_count):
		var path_follow = PathFollow3D.new()
		path_follow.name = "PathFollow_" + path.name + "_" + str(i)
		path_follow.loop = false
		path_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
		path.add_child(path_follow)
		
		# Set progress based on calculated position
		path_follow.progress = positions[i]
		
		# Select scene based on selection mode
		var selected_scene = _select_scene(available_scenes, i)
		var obj = selected_scene.instantiate()
		path_follow.add_child(obj)
		
		# Apply random variations
		_apply_variations(obj)
		
		# Assign owner for saving in scene
		if get_tree().edited_scene_root:
			obj.owner = get_tree().edited_scene_root
			path_follow.owner = get_tree().edited_scene_root

func generate_objects_direct(path: Path3D, object_count: int, available_scenes: Array[PackedScene]) -> void:
	var path_length = path.curve.get_baked_length()
	if path_length <= 0 or object_count <= 0 or available_scenes.is_empty():
		return
	
	var positions = _calculate_positions(object_count, path_length)
	
	for i in range(object_count):
		var path_position = path.curve.sample_baked(positions[i])
		
		# Select scene based on selection mode
		var selected_scene = _select_scene(available_scenes, i)
		var obj = selected_scene.instantiate()
		path.add_child(obj)
		obj.position = path_position
		
		# Orient object along curve (optional)
		if i < object_count - 1:
			var next_pos = positions[i + 1] if i + 1 < positions.size() else positions[i] + 1.0
			var look_pos = path.curve.sample_baked(min(next_pos, path_length))
			if look_pos != path_position:
				obj.look_at(look_pos, Vector3.UP)
		
		# Apply random variations
		_apply_variations(obj)
		
		# Assign owner for saving in scene
		if get_tree().edited_scene_root:
			obj.owner = get_tree().edited_scene_root

func _calculate_positions(object_count: int, path_length: float) -> Array[float]:
	var positions: Array[float] = []
	
	match object_spacing_mode:
		SpacingMode.EVEN:
			for i in range(object_count):
				var progress = float(i) / float(object_count - 1) if object_count > 1 else 0.0
				positions.append(progress * path_length)
		
		SpacingMode.RANDOM:
			for i in range(object_count):
				positions.append(randf() * path_length)
			positions.sort()
		
		SpacingMode.CLUSTERED:
			var cluster_count = max(1, object_count / 3)
			var cluster_positions = []
			for i in range(cluster_count):
				cluster_positions.append(randf() * path_length)
			
			for i in range(object_count):
				var cluster_idx = i % cluster_count
				var cluster_pos = cluster_positions[cluster_idx]
				var offset = (randf() - 0.5) * (path_length * 0.1)  # 10% of path length variation
				positions.append(clamp(cluster_pos + offset, 0, path_length))
	
	return positions

func _select_scene(available_scenes: Array[PackedScene], index: int) -> PackedScene:
	if random_object_selection:
		return available_scenes[randi() % available_scenes.size()]
	else:
		return available_scenes[index % available_scenes.size()]

func _apply_variations(obj: Node3D) -> void:
	if add_random_rotation:
		obj.rotation_degrees.y = randf() * 360.0
	
	if random_scale_variation > 0.0:
		var scale_factor = 1.0 + (randf() - 0.5) * random_scale_variation
		obj.scale *= scale_factor

func clear_objects() -> void:
	# Clear based on placement method
	if use_direct_placement:
		# Remove direct objects
		for path in get_path_children():
			for child in path.get_children():
				if not child is PathFollow3D and not child is Path3D:
					child.queue_free()
	else:
		# Remove PathFollow3D with their objects
		for path in get_path_children():
			for child in path.get_children():
				if child is PathFollow3D:
					child.queue_free()

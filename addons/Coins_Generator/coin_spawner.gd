@tool
extends Node3D

@export var coin_scene: PackedScene
@export var total_coins: int = 10
@export_group("Advanced Options")
@export var use_direct_placement: bool = true
@export var distribute_by_length: bool = false

@export_group("Generation")
@export var generate_coins_button: bool = false:
	set(value):
		generate_coins_button = false
		generate_coins()

var _last_children_count: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

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
		warnings.append("No Path3D nodes found. Add Path3D nodes as children to generate coins.")
	return warnings



func add_generate_button() -> void:
	# Crear un botón
	var button = Button.new()
	button.text = "Generate Coins"
	button.connect("pressed", Callable(self, "generate_coins"))
	
	# Agregar el botón al inspector
	add_child(button)
	button.owner = get_tree().edited_scene_root
	
	# Configurar el botón para que aparezca en el inspector
	button.set_meta("_edit_group_", true)
	button.set_meta("_edit_use_custom_anchors_", false)

func update_generate_button() -> void:
	# Actualizar el estado del botón basado en la presencia de Path3D
	var button = get_node_or_null("Button")
	if button:
		button.disabled = get_path_children().size() == 0

# El resto de las funciones permanecen iguales...

func generate_coins() -> void:
	if not coin_scene:
		print("Error: No se ha asignado una escena de moneda")
		return
	
	clear_coins()
	
	var paths = get_path_children()
	if paths.size() == 0:
		print("Advertencia: No se encontraron nodos Path3D como hijos del CoinSpawner")
		return
	
	if total_coins <= 0:
		return
	
	# Calcular distribución de monedas entre los caminos
	var coins_per_path = calculate_coin_distribution(paths)
	
	# Distribuir monedas en cada Path3D según la distribución calculada
	for i in range(paths.size()):
		var path = paths[i]
		var coins_for_this_path = coins_per_path[i]
		
		if use_direct_placement:
			generate_coins_direct(path, coins_for_this_path)
		else:
			generate_coins_with_pathfollow(path, coins_for_this_path)



# Obtener todos los hijos que son Path3D
func get_path_children() -> Array:
	var paths = []
	for child in get_children():
		if child is Path3D:
			paths.append(child)
	return paths


# Calcular cuántas monedas debe tener cada camino
func calculate_coin_distribution(paths: Array) -> Array:
	var result = []
	var num_paths = paths.size()
	
	if distribute_by_length:
		# Distribuir basado en longitud relativa de cada camino
		var total_length = 0.0
		var lengths = []
		
		# Calcular longitud total y longitud individual
		for path in paths:
			var length = path.curve.get_baked_length()
			total_length += length
			lengths.append(length)
		
		# Calcular monedas para cada camino basado en su proporción de longitud
		for i in range(num_paths):
			var proportion = lengths[i] / total_length if total_length > 0 else 0
			var coins = int(round(proportion * total_coins))
			result.append(coins)
		
		# Ajustar para asegurar que el total sea correcto
		var current_total = result.reduce(func(accum, coins): return accum + coins, 0)
		while current_total != total_coins:
			if current_total < total_coins:
				# Añadir monedas a los caminos más largos primero
				var max_length_idx = lengths.find(lengths.max())
				result[max_length_idx] += 1
			else:
				# Quitar monedas de los caminos más cortos primero
				var min_length_idx = lengths.find(lengths.min())
				if result[min_length_idx] > 0:
					result[min_length_idx] -= 1
				else:
					var idx_with_coins = result.find(result.max())
					result[idx_with_coins] -= 1
			
			current_total = result.reduce(func(accum, coins): return accum + coins, 0)
	else:
		# Distribución equitativa simple
		var base_count = total_coins / num_paths
		var remainder = total_coins % num_paths
		
		for i in range(num_paths):
			result.append(base_count + (1 if i < remainder else 0))
	
	return result

# Generar monedas usando PathFollow3D (mejor para animaciones y movimiento)
func generate_coins_with_pathfollow(path: Path3D, coin_count: int) -> void:
	var path_length = path.curve.get_baked_length()
	if path_length <= 0 or coin_count <= 0:
		return
	
	for i in range(coin_count):
		var path_follow = PathFollow3D.new()
		path_follow.name = "PathFollow_" + path.name + "_" + str(i)
		path_follow.progress_ratio = float(i) / float(coin_count)
		path_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
		path.add_child(path_follow)
		
		var coin = coin_scene.instantiate()
		path_follow.add_child(coin)
		
		# Asignar el propietario para que se guarde en la escena
		if get_tree().edited_scene_root:
			coin.owner = get_tree().edited_scene_root
			path_follow.owner = get_tree().edited_scene_root

# Generar monedas directamente en posiciones a lo largo de la curva (más simple)
func generate_coins_direct(path: Path3D, coin_count: int) -> void:
	var path_length = path.curve.get_baked_length()
	if path_length <= 0 or coin_count <= 0:
		return
	
	for i in range(coin_count):
		var offset = float(i) / float(coin_count)
		var path_position = path.curve.sample_baked(offset * path_length)
		
		var coin = coin_scene.instantiate()
		path.add_child(coin)
		coin.position = path_position
		
		# Para orientar la moneda a lo largo de la curva (opcional)
		if i < coin_count - 1:
			var look_pos = path.curve.sample_baked(min((offset + 0.01) * path_length, path_length))
			coin.look_at(look_pos, Vector3.UP)
		
		# Asignar el propietario para que se guarde en la escena
		if get_tree().edited_scene_root:
			coin.owner = get_tree().edited_scene_root

func clear_coins() -> void:
	# Limpiar según el método de colocación
	if use_direct_placement:
		# Eliminar monedas directas
		for path in get_path_children():
			for child in path.get_children():
				if not child is PathFollow3D and not child is Path3D:
					child.queue_free()
	else:
		# Eliminar PathFollow3D con sus monedas
		for path in get_path_children():
			for child in path.get_children():
				if child is PathFollow3D:
					child.queue_free()

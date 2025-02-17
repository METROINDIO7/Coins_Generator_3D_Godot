@tool
extends EditorPlugin

func _enter_tree():
	# Agregar el nodo CoinSpawner al editor como un tipo personalizado
	var icon = get_editor_interface().get_base_control().get_theme_icon("Node3D", "EditorIcons")
	add_custom_type("CoinSpawner", "Node3D", preload("res://addons/Coins_Generator/coin_spawner.gd"), icon)
	
	# Agregar una entrada de menú para crear el spawner
	add_tool_menu_item("Create Coin Spawner", Callable(self, "create_coin_spawner"))

func _exit_tree():
	# Eliminar el nodo personalizado del editor al deshabilitar el plugin
	remove_custom_type("CoinSpawner")
	remove_tool_menu_item("Create Coin Spawner")

func create_coin_spawner():
	var edited_scene = get_editor_interface().get_edited_scene_root()
	if edited_scene:
		var coin_spawner = preload("res://addons/Coins_Generator/coin_spawner.tscn").instantiate()
		edited_scene.add_child(coin_spawner)
		coin_spawner.owner = edited_scene
		
		# Usar nombre distintivo
		coin_spawner.name = "CoinSpawner"
		
		# Notificar al editor que realizamos un cambio
		get_editor_interface().get_selection().clear()
		get_editor_interface().get_selection().add_node(coin_spawner)

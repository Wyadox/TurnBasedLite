extends Control

var option

func _on_human_button_pressed() -> void:
	option = "human"
	load_game_scene()

func _on_ai_button_pressed() -> void:
	option = "ai"
	load_game_scene()

func load_game_scene():
	var player_type : Globals.PLAYER_2_TYPE
	if option == "human":
		player_type = Globals.PLAYER_2_TYPE.HUMAN
	else:
		player_type = Globals.PLAYER_2_TYPE.AI
		
	const GAME_SCENE = preload("res://scenes/map_menu.tscn")
	var game_scene = GAME_SCENE.instantiate()
	
	game_scene.player2_type = player_type
	
	var scene_tree = get_tree()
	scene_tree.current_scene.queue_free()
	scene_tree.root.add_child(game_scene)
	scene_tree.current_scene = game_scene

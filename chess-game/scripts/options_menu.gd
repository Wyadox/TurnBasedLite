extends Control

@onready var opponent_option_button: OptionButton = $Panel/VBoxContainer/Opponent_OptionButton
@onready var difficulty_option_button: OptionButton = $Panel/VBoxContainer/Difficulty_OptionButton
@onready var notification_node: Control = $notification

var current_map : int = -1
var color : Globals.COLORS
var game_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	const GAME_SCENE = preload("res://scenes/game.tscn")
	game_scene = GAME_SCENE.instantiate()
	
func _on_continue_button_pressed() -> void:
	if opponent_option_button.get_selected_id() == -1 or difficulty_option_button.get_selected_id() == -1 or current_map == -1:
		notification_node.set_text("An option was not selected")
		return
	
	#print("options menu")
	
	
	game_scene.player2_type = convert_opponent_option(opponent_option_button.get_item_text(opponent_option_button.get_selected_id()))
	game_scene.difficulty = Globals.DIFFICULTY[difficulty_option_button.get_item_text(difficulty_option_button.get_selected_id())]
	game_scene.current_map = current_map
	#print("game scene current map is")
	#print(game_scene.current_map)
	
	
	
	var scene_tree = get_tree()
	scene_tree.current_scene.queue_free()
	if game_scene.player2_type == Globals.PLAYER_2_TYPE.HUMAN:
		scene_tree.root.add_child(game_scene)
		scene_tree.current_scene = game_scene
		SignalBus.emit_signal("change_map",current_map)
	else:
		const COLOR_SCENE = preload("res://scenes/color_menu.tscn")
		var color_scene = COLOR_SCENE.instantiate()
		color_scene.current_map = current_map
		
		color_scene.load_scene = game_scene
		
		
		scene_tree.current_scene.queue_free()
		scene_tree.root.add_child(color_scene)
		scene_tree.current_scene = color_scene
		
	
func convert_opponent_option(option : String) -> Globals.PLAYER_2_TYPE:
	if option == "HUMAN":
		return Globals.PLAYER_2_TYPE.HUMAN
	else:
		return Globals.PLAYER_2_TYPE.AI

func _on_map_1_button_pressed() -> void:
	current_map = 1
	print(current_map)


func _on_map_2_button_pressed() -> void:
	current_map = 2
	print(current_map)


func _on_map_3_button_pressed() -> void:
	current_map = 3
	print(current_map)


func _on_map_4_button_pressed() -> void:
	current_map = 4
	print(current_map)

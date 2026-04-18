extends Control

@onready var opponent_option_button: OptionButton = $chess_background/VBoxContainer/Opponent_OptionButton
@onready var notification_node: Control = $notification
@onready var continue_button: DynamicButton = $chess_background/VBoxContainer/HBoxContainer/Continue_Button
@onready var difficulty_map_options_menu: Control = $chess_background/VBoxContainer/difficulty_map_options_menu
@onready var return_button: DynamicButton = $Return_Button

var current_map : int = -1
var current_difficulty : int = -1
var color : Globals.COLORS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	continue_button.button_triggered.connect(_on_continue_button_pressed)
	return_button.button_triggered.connect(_on_button_exit_pressed)
	
	continue_button.condition = false
	
func _on_continue_button_pressed() -> void:
	current_difficulty = difficulty_map_options_menu.difficulty
	current_map = difficulty_map_options_menu.map
	
	if opponent_option_button.get_selected_id() == -1 or current_difficulty == -1 or current_map == -1:
		notification_node.set_text("An option was not selected")
		return
	
	continue_button.condition = true
	
	var GAME_SCENE = load("res://scenes/game.tscn")
	if GAME_SCENE == null:
		push_error("game.tscn really??")
		return
	var game_scene : Game = GAME_SCENE.instantiate()
	
	game_scene.player2_type = convert_opponent_option(opponent_option_button.get_item_text(opponent_option_button.get_selected_id()))
	game_scene.difficulty = current_difficulty as Globals.DIFFICULTY
	game_scene.current_map = current_map
	
	var scene_tree = get_tree()
	scene_tree.current_scene.queue_free()
	if game_scene.player2_type == Globals.PLAYER_2_TYPE.HUMAN:
		scene_tree.root.add_child(game_scene)
		scene_tree.current_scene = game_scene
		SignalBus.emit_signal("change_map", current_map)
	else:
		const COLOR_SCENE = preload("res://scenes/color_menu.tscn")
		var color_scene = COLOR_SCENE.instantiate()
		
		color_scene.load_scene = game_scene
		
		scene_tree.root.add_child(color_scene)
		scene_tree.current_scene = color_scene
	
func convert_opponent_option(option : String) -> Globals.PLAYER_2_TYPE:
	if option == "HUMAN":
		return Globals.PLAYER_2_TYPE.HUMAN
	else:
		return Globals.PLAYER_2_TYPE.AI

func _on_button_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

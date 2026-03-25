extends Control
@onready var map_1_button: TextureButton = $VBoxContainer/HBoxContainer/Map1_Button
@onready var map_2_button: TextureButton = $VBoxContainer/HBoxContainer/Map2_Button
@onready var map_3_button: TextureButton = $VBoxContainer/HBoxContainer2/Map3_Button
@onready var map_4_button: TextureButton = $VBoxContainer/HBoxContainer2/Map4_Button

var current_map : int
var player2_type : Globals.PLAYER_2_TYPE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _on_continue_button_pressed() -> void:
	const GAME_SCENE = preload("res://scenes/game.tscn")
	var game_scene = GAME_SCENE.instantiate()
	
	game_scene.player2_type = player2_type
	game_scene.current_map = current_map
	SignalBus.emit_signal("change_map",current_map)
	
	var scene_tree = get_tree()
	scene_tree.current_scene.queue_free()
	scene_tree.root.add_child(game_scene)
	scene_tree.current_scene = game_scene


func _on_map_1_button_pressed() -> void:
	current_map = 1

func _on_map_2_button_pressed() -> void:
	current_map = 2

func _on_map_3_button_pressed() -> void:
	current_map = 3

func _on_map_4_button_pressed() -> void:
	current_map = 4

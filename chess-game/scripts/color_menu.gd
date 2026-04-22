extends Control

@onready var continue_button: DynamicButton = $chess_background/VBoxContainer/HBoxContainer/Continue_Button
@onready var spinner: Spinner = $chess_background/VBoxContainer/spinner
@onready var return_button: DynamicButton = $Return_Button

var load_scene
var player_color : Globals.COLORS

func _ready() -> void:
	continue_button.disable()
	continue_button.button_triggered.connect(_on_continue_button_pressed)
	
	spinner.result.connect(process_result)
	
	return_button.button_triggered.connect(on_return)

func _on_continue_button_pressed() -> void:
	if player_color == Globals.COLORS.WHITE:
		load_scene.ai_color = Globals.COLORS.BLACK
	else:
		load_scene.ai_color = Globals.COLORS.WHITE
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(load_scene)
	get_tree().current_scene = load_scene
	SignalBus.emit_signal("change_map", load_scene.current_map)

func process_result(color : Globals.COLORS):
	player_color = color
	
	continue_button.enable()

func on_return():
	get_tree().change_scene_to_file("res://scenes/local_options_menu.tscn")

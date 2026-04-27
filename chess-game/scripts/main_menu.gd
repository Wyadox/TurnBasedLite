extends Control

@onready var main_menu_ui = $"."
@onready var title: TextureRect = $Title

@onready var local_button: DynamicButton = $VBoxContainer/Local_Button
@onready var multiplayer_button: DynamicButton = $VBoxContainer/Multiplayer_Button
@onready var loadout_button: DynamicButton = $VBoxContainer/Loadout_Button
@onready var options_button: DynamicButton = $VBoxContainer/Options_Button
@onready var quit_button: DynamicButton = $VBoxContainer/Quit_Button

var direction : int = 1
const ROTATION_INCREMENT : float = 0.25

func _ready() -> void:
	local_button.button_triggered.connect(_on_start_button_pressed)
	multiplayer_button.button_triggered.connect(_on_online_button_pressed)
	loadout_button.button_triggered.connect(_on_loadout_button_pressed)
	options_button.button_triggered.connect(_on_options_button_pressed)

func _process(delta: float) -> void:
	if !SettingsManager.get_settings().play_animations:
		return
	
	title.rotation += ROTATION_INCREMENT * direction * delta
	if title.rotation > deg_to_rad(10.0) or title.rotation < deg_to_rad(-10):
		direction *= -1

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/local_options_menu.tscn")

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_loadout_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/loadout_menu.tscn")


func _on_online_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

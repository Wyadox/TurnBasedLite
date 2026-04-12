extends Control

@onready var main_menu_ui = $"."
@onready var title: TextureRect = $Title

var direction : int = 1
const ROTATION_INCREMENT : float = 0.25

func _process(delta: float) -> void:
	title.rotation += ROTATION_INCREMENT * direction * delta
	if title.rotation > deg_to_rad(10.0) or title.rotation < deg_to_rad(-10):
		direction *= -1

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/local_options_menu.tscn")

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_loadout_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/loadout_menu.tscn")

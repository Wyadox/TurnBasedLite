extends Control

@onready var main_menu_ui = $"."

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/opponent_ui.tscn")

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/descriptions.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

extends Control

var difficulty : int = -1
var map : int = -1

func _on_easy_button_pressed() -> void:
	difficulty = 0

func _on_normal_button_pressed() -> void:
	difficulty = 1

func _on_hard_button_pressed() -> void:
	difficulty = 2

func _on_map_1_button_pressed() -> void:
	map = 1

func _on_map_2_button_pressed() -> void:
	map = 2

func _on_map_3_button_pressed() -> void:
	map = 3

func _on_map_4_button_pressed() -> void:
	map = 4

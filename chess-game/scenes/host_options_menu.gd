extends Control

signal host_button_pressed

@onready var difficulty_map_options_menu: Control = $Panel/MarginContainer/VBoxContainer/difficulty_map_options_menu

var color : Globals.COLORS

func _on_white_button_pressed() -> void:
	color = Globals.COLORS.WHITE

func _on_black_button_pressed() -> void:
	color = Globals.COLORS.BLACK

func _on_half_button_pressed() -> void:
	var roll = randf()
	if roll < 0.5:
		color = Globals.COLORS.WHITE
	else:
		color = Globals.COLORS.BLACK

func _on_host_button_pressed() -> void:
	host_button_pressed.emit()

func get_difficulty():
	return difficulty_map_options_menu.difficulty

func get_map():
	return difficulty_map_options_menu.map

func get_color():
	return color

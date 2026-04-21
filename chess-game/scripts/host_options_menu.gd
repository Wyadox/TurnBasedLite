extends Control

signal host_button_pressed

@onready var difficulty_map_options_menu: Control = $chess_background/MarginContainer/VBoxContainer/difficulty_map_options_menu
@onready var host_button: DynamicButton = $chess_background/MarginContainer/VBoxContainer/HBoxContainer2/Host_Button
@onready var white_button: DynamicButton = $chess_background/MarginContainer/VBoxContainer/HBoxContainer/White_Button
@onready var half_button: DynamicButton = $chess_background/MarginContainer/VBoxContainer/HBoxContainer/Half_Button
@onready var black_button: DynamicButton = $chess_background/MarginContainer/VBoxContainer/HBoxContainer/Black_Button

var color : Globals.COLORS

func _ready() -> void:
	host_button.button_triggered.connect(_on_host_button_pressed)
	white_button.button_triggered.connect(_on_white_button_pressed)
	half_button.button_triggered.connect(_on_half_button_pressed)
	black_button.button_triggered.connect(_on_black_button_pressed)

func _on_white_button_pressed() -> void:
	color = Globals.COLORS.WHITE
	deselect_color()
	white_button.select()

func _on_black_button_pressed() -> void:
	color = Globals.COLORS.BLACK
	deselect_color()
	black_button.select()

func _on_half_button_pressed() -> void:
	var roll = randf()
	if roll < 0.5:
		color = Globals.COLORS.WHITE
	else:
		color = Globals.COLORS.BLACK
	
	deselect_color()
	half_button.select()

func _on_host_button_pressed() -> void:
	if difficulty_map_options_menu.difficulty != -1 and difficulty_map_options_menu.map != -1 and color != null:
		host_button_pressed.emit()

func get_difficulty():
	return difficulty_map_options_menu.difficulty

func get_map():
	return difficulty_map_options_menu.map

func get_color():
	return color

func deselect_color():
	white_button.deselect()
	half_button.deselect()
	black_button.deselect()

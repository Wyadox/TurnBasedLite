extends Control

@onready var notification_node: Control = $notification
@onready var difficulty_map_options_menu: Control = $chess_background/VBoxContainer/difficulty_map_options_menu
@onready var return_button: DynamicButton = $Return_Button
@onready var tool_on_button: DynamicButton = $chess_background/VBoxContainer/HBoxContainer2/Tool_On_Button
@onready var tool_off_button: DynamicButton = $chess_background/VBoxContainer/HBoxContainer2/Tool_Off_Button
@onready var tooltip: Control = $Tooltip

func _ready() -> void:
	return_button.button_triggered.connect(_on_button_exit_pressed)
	
	tool_on_button.button_triggered.connect(on_tool_on_button)
	tool_off_button.button_triggered.connect(on_tool_off_button)
	
	if Globals.show_tooltips:
		on_tool_on_button()
	else:
		on_tool_off_button()

func _on_button_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func on_tool_on_button():
	Globals.show_tooltips = true
	tooltip.show()
	
	tool_on_button.select()
	tool_off_button.deselect()

func on_tool_off_button():
	Globals.show_tooltips = false
	tooltip.hide()
	
	tool_on_button.deselect()
	tool_off_button.select()

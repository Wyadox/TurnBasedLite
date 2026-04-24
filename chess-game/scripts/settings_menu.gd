extends Control

@onready var notification_node: Control = $notification
@onready var difficulty_map_options_menu: Control = $chess_background/VBoxContainer/difficulty_map_options_menu
@onready var return_button: DynamicButton = $Return_Button
@onready var tool_on_button: DynamicButton = $chess_background/VBoxContainer/HBoxContainer2/Tool_On_Button
@onready var tool_off_button: DynamicButton = $chess_background/VBoxContainer/HBoxContainer2/Tool_Off_Button
@onready var tooltip: Control = $Tooltip

@onready var window_option_button: OptionButton = $chess_background/VBoxContainer/VBoxContainer/Window_OptionButton
@onready var resolution_option_button: OptionButton = $chess_background/VBoxContainer/VBoxContainer/Resolution_OptionButton

var window_modes : Dictionary = {
	"Fullscreen" : DisplayServer.WINDOW_MODE_FULLSCREEN,
	"Window" : DisplayServer.WINDOW_MODE_WINDOWED,
	"Window Maximized" : DisplayServer.WINDOW_MODE_MAXIMIZED
}

var resolutions : Dictionary = {
	"320x180" : Vector2i(320, 180),
	"480x270" : Vector2i(480, 270),
	"640x360" : Vector2i(640, 360),
	"1280x720" : Vector2i(1280, 720),
	"1920x1080" : Vector2i(1920, 1080)
}

func _ready() -> void:
	for window_mode in window_modes:
		window_option_button.add_item(window_mode)
	window_option_button.select(SettingsManager.get_settings().window_mode_index)
	
	for resolution in resolutions:
		resolution_option_button.add_item(resolution)
	resolution_option_button.select(SettingsManager.get_settings().resolution_index)
	
	return_button.button_triggered.connect(_on_button_exit_pressed)
	
	tool_on_button.button_triggered.connect(on_tool_on_button)
	tool_off_button.button_triggered.connect(on_tool_off_button)
	
	if SettingsManager.get_settings().show_tooltips:
		on_tool_on_button()
	else:
		on_tool_off_button()

func _on_button_exit_pressed() -> void:
	SettingsManager.save_settings()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func on_tool_on_button():
	SettingsManager.set_show_tooltips(true)
	tooltip.show()
	
	tool_on_button.select()
	tool_off_button.deselect()

func on_tool_off_button():
	SettingsManager.set_show_tooltips(false)
	tooltip.hide()
	
	tool_on_button.deselect()
	tool_off_button.select()

func _on_window_option_button_item_selected(index: int) -> void:
	var window_mode = window_modes.get(window_option_button.get_item_text(index)) as int
	SettingsManager.set_window_mode(window_mode, index)


func _on_resolution_option_button_item_selected(index: int) -> void:
	var resolution = resolutions.get(resolution_option_button.get_item_text(index)) as Vector2i
	SettingsManager.set_resolution(resolution, index)

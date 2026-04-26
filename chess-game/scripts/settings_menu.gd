extends Control

@onready var notification_node: Control = $notification
@onready var difficulty_map_options_menu: Control = $chess_background/VBoxContainer/difficulty_map_options_menu
@onready var return_button: DynamicButton = $Return_Button
@onready var tooltip: Control = $Tooltip

@onready var tool_on_button: DynamicButton = $chess_background/MarginContainer/HBoxContainer/Toggles_VBOX/VBoxContainer3/HBoxContainer2/Tool_On_Button
@onready var tool_off_button: DynamicButton = $chess_background/MarginContainer/HBoxContainer/Toggles_VBOX/VBoxContainer3/HBoxContainer2/Tool_Off_Button
@onready var eval_on_button: DynamicButton = $chess_background/MarginContainer/HBoxContainer/Toggles_VBOX/VBoxContainer3/HBoxContainer3/Eval_On_Button
@onready var eval_off_button: DynamicButton = $chess_background/MarginContainer/HBoxContainer/Toggles_VBOX/VBoxContainer3/HBoxContainer3/Eval_Off_Button
@onready var highlight_on_button: DynamicButton = $chess_background/MarginContainer/HBoxContainer/Toggles_VBOX/VBoxContainer3/HBoxContainer4/Highlight_On_Button
@onready var highlight_off_button: DynamicButton = $chess_background/MarginContainer/HBoxContainer/Toggles_VBOX/VBoxContainer3/HBoxContainer4/Highlight_Off_Button
@onready var animations_on_button: DynamicButton = $chess_background/MarginContainer/HBoxContainer/Toggles_VBOX/VBoxContainer3/HBoxContainer5/Animations_On_Button
@onready var animations_off_button: DynamicButton = $chess_background/MarginContainer/HBoxContainer/Toggles_VBOX/VBoxContainer3/HBoxContainer5/Animations_Off_Button
@onready var particles_on_button: DynamicButton = $chess_background/MarginContainer/HBoxContainer/Toggles_VBOX/VBoxContainer3/HBoxContainer6/Particles_On_Button
@onready var particles_off_button: DynamicButton = $chess_background/MarginContainer/HBoxContainer/Toggles_VBOX/VBoxContainer3/HBoxContainer6/Particles_Off_Button

@onready var window_option_button: OptionButton = $chess_background/MarginContainer/HBoxContainer/Display_Volume_VBOX/VBoxContainer/Window_OptionButton
@onready var resolution_option_button: OptionButton = $chess_background/MarginContainer/HBoxContainer/Display_Volume_VBOX/VBoxContainer/Resolution_OptionButton

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
	eval_on_button.button_triggered.connect(on_eval_on)
	eval_off_button.button_triggered.connect(on_eval_off)
	highlight_on_button.button_triggered.connect(on_highlight_on)
	highlight_off_button.button_triggered.connect(on_highlight_off)
	animations_on_button.button_triggered.connect(on_animation_on)
	animations_off_button.button_triggered.connect(on_animation_off)
	particles_on_button.button_triggered.connect(on_particle_on)
	particles_off_button.button_triggered.connect(on_particle_off)
	
	if SettingsManager.get_settings().show_tooltips:
		on_tool_on_button()
	else:
		on_tool_off_button()
	
	if SettingsManager.get_settings().show_eval:
		on_eval_on()
	else:
		on_eval_off()
	
	if SettingsManager.get_settings().show_previous:
		on_highlight_on()
	else:
		on_highlight_off()
	
	if SettingsManager.get_settings().play_animations:
		on_animation_on()
	else:
		on_animation_off()
	
	if SettingsManager.get_settings().play_particles:
		on_particle_on()
	else:
		on_particle_off()

func _on_button_exit_pressed() -> void:
	SettingsManager.save_settings()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func on_tool_on_button():
	SettingsManager.set_toggle(SettingsManager.TOGGLES.TOOLTIPS, true)
	tooltip.show()
	
	tool_on_button.select()
	tool_off_button.deselect()

func on_tool_off_button():
	SettingsManager.set_toggle(SettingsManager.TOGGLES.TOOLTIPS, false)
	tooltip.hide()
	
	tool_on_button.deselect()
	tool_off_button.select()

func on_eval_on():
	SettingsManager.set_toggle(SettingsManager.TOGGLES.EVAL, true)
	
	eval_on_button.select()
	eval_off_button.deselect()

func on_eval_off():
	SettingsManager.set_toggle(SettingsManager.TOGGLES.EVAL, false)
	
	eval_on_button.deselect()
	eval_off_button.select()

func on_highlight_on():
	SettingsManager.set_toggle(SettingsManager.TOGGLES.PREVIOUS, true)
	
	highlight_on_button.select()
	highlight_off_button.deselect()

func on_highlight_off():
	SettingsManager.set_toggle(SettingsManager.TOGGLES.PREVIOUS, false)
	
	highlight_on_button.deselect()
	highlight_off_button.select()

func on_animation_on():
	SettingsManager.set_toggle(SettingsManager.TOGGLES.ANIMATIONS, true)
	
	animations_on_button.select()
	animations_off_button.deselect()

func on_animation_off():
	SettingsManager.set_toggle(SettingsManager.TOGGLES.ANIMATIONS, false)
	
	animations_on_button.deselect()
	animations_off_button.select()

func on_particle_on():
	SettingsManager.set_toggle(SettingsManager.TOGGLES.PARTICLES, true)
	
	particles_on_button.select()
	particles_off_button.deselect()

func on_particle_off():
	SettingsManager.set_toggle(SettingsManager.TOGGLES.PARTICLES, false)
	
	particles_on_button.deselect()
	particles_off_button.select()

func _on_window_option_button_item_selected(index: int) -> void:
	var window_mode = window_modes.get(window_option_button.get_item_text(index)) as int
	SettingsManager.set_window_mode(window_mode, index)


func _on_resolution_option_button_item_selected(index: int) -> void:
	var resolution = resolutions.get(resolution_option_button.get_item_text(index)) as Vector2i
	SettingsManager.set_resolution(resolution, index)

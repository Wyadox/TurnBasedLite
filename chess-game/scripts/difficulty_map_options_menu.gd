extends Control

@onready var easy_button: DynamicButton = $VBoxContainer/Difficulty_Hbox/Easy_Button
@onready var normal_button: DynamicButton = $VBoxContainer/Difficulty_Hbox/Normal_Button
@onready var hard_button: DynamicButton = $VBoxContainer/Difficulty_Hbox/Hard_Button

var difficulty : int = -1
var map : int = -1

func _ready() -> void:
	easy_button.button_triggered.connect(_on_easy_button_pressed)
	normal_button.button_triggered.connect(_on_normal_button_pressed)
	hard_button.button_triggered.connect(_on_hard_button_pressed)

func _on_easy_button_pressed() -> void:
	difficulty = 0
	deselect_difficulties()
	easy_button.select()

func _on_normal_button_pressed() -> void:
	difficulty = 1
	deselect_difficulties()
	normal_button.select()

func _on_hard_button_pressed() -> void:
	difficulty = 2
	deselect_difficulties()
	hard_button.select()

func _on_map_1_button_pressed() -> void:
	map = 1

func _on_map_2_button_pressed() -> void:
	map = 2

func _on_map_3_button_pressed() -> void:
	map = 3

func _on_map_4_button_pressed() -> void:
	map = 4

func deselect_difficulties():
	easy_button.deselect()
	normal_button.deselect()
	hard_button.deselect()

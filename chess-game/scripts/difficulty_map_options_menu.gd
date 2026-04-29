extends Control

@onready var easy_button: DynamicButton = $VBoxContainer/Difficulty_Hbox/Easy_Button
@onready var normal_button: DynamicButton = $VBoxContainer/Difficulty_Hbox/Normal_Button
@onready var hard_button: DynamicButton = $VBoxContainer/Difficulty_Hbox/Hard_Button
@onready var standard_button: DynamicButton = $VBoxContainer/HBoxContainer/dynamic_button
@onready var river_button: DynamicButton = $VBoxContainer/HBoxContainer/dynamic_button2
@onready var forest_button: DynamicButton = $VBoxContainer/HBoxContainer2/dynamic_button3
@onready var wall_button: DynamicButton = $VBoxContainer/HBoxContainer2/dynamic_button4



var difficulty : int = -1
var map : int = -1

func _ready() -> void:
	easy_button.button_triggered.connect(_on_easy_button_pressed)
	normal_button.button_triggered.connect(_on_normal_button_pressed)
	hard_button.button_triggered.connect(_on_hard_button_pressed)
	standard_button.button_triggered.connect(_on_standard_button_pressed)
	river_button.button_triggered.connect(_on_river_button_pressed)
	forest_button.button_triggered.connect(_on_forest_button_pressed)
	wall_button.button_triggered.connect(_on_wall_button_pressed)

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

func _on_standard_button_pressed() -> void:
	map = 1
	deselect_maps()
	standard_button.select()

func _on_river_button_pressed() -> void:
	map = 2
	deselect_maps()
	river_button.select()

func _on_forest_button_pressed() -> void:
	map = 3
	deselect_maps()
	forest_button.select()

func _on_wall_button_pressed() -> void:
	map = 4
	deselect_maps()
	wall_button.select()

func deselect_difficulties():
	easy_button.deselect()
	normal_button.deselect()
	hard_button.deselect()

func deselect_maps():
	standard_button.deselect()
	river_button.deselect()
	forest_button.deselect()
	wall_button.deselect()

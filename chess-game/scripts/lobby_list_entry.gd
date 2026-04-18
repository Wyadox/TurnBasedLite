class_name LobbyListEntry
extends Button


@onready var background_color_rect: ColorRect = $BackgroundColor
@onready var number_label: Label = $MarginContainer/HBoxContainer/Number_Label
@onready var title_label: Label = $MarginContainer/HBoxContainer/Title_Label
@onready var details_label: Label = $MarginContainer/HBoxContainer/Details_Label

@onready var color_image: TextureRect = $MarginContainer/HBoxContainer/Color_Image
@onready var map_image: TextureRect = $MarginContainer/HBoxContainer/Map_Image
@onready var difficulty_image: TextureRect = $MarginContainer/HBoxContainer/Difficulty_Image

var description : String

@export var background_color : Color
@export var number : int
@export var title : String
@export var details : String

func _ready() -> void:
	background_color_rect.color = background_color
	number_label.text = "#" + str(number)
	title_label.text = title
	details_label.text = details

func set_textures(difficulty : Globals.DIFFICULTY, host_color : Globals.COLORS, map : int):
	match difficulty:
		Globals.DIFFICULTY.EASY:
			difficulty_image.texture = preload("res://Assets/LobbyMenuImages/EasyModeIconJug.png")
		Globals.DIFFICULTY.NORMAL:
			difficulty_image.texture = preload("res://Assets/LobbyMenuImages/NormalModeIconJug.png")
		Globals.DIFFICULTY.HARD:
			difficulty_image.texture = preload("res://Assets/LobbyMenuImages/HardModeIconJug.png")
	
	match host_color:
		Globals.COLORS.WHITE:
			color_image.texture = preload("res://Assets/LobbyMenuImages/BlackShieldKing.png")
		Globals.COLORS.BLACK:
			color_image.texture = preload("res://Assets/LobbyMenuImages/WhiteShieldKing.png")
	
	match map:
		1: 
			map_image.texture = preload("res://Assets/Buttons/LoadoutButton.png")
		2: 
			map_image.texture = preload("res://Assets/Buttons/LoadoutButton.png")
		3: 
			map_image.texture = preload("res://Assets/Buttons/LoadoutButton.png")
		4: 
			map_image.texture = preload("res://Assets/Buttons/LoadoutButton.png")

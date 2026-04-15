class_name LobbyListEntry
extends Button


@onready var background_color_rect: ColorRect = $BackgroundColor
@onready var number_label: Label = $MarginContainer/HBoxContainer/Number_Label
@onready var title_label: Label = $MarginContainer/HBoxContainer/Title_Label
@onready var details_label: Label = $MarginContainer/HBoxContainer/Details_Label

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

class_name MoveHistoryEntry
extends Control

@onready var image: TextureRect = $MarginContainer/HBoxContainer/TextureRect
@onready var label: Label = $MarginContainer/HBoxContainer/Label

func set_display(atlas : AtlasTexture, text : String):
	image.texture = atlas
	label.text = text

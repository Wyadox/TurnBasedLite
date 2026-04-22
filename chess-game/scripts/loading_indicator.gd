class_name LoadingIndicator
extends Control

@onready var loading_indicator: TextureProgressBar = $HBoxContainer/loading_indicator
@onready var label: Label = $HBoxContainer/Label

@export var display_text : String

func _ready() -> void:
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property(loading_indicator, "radial_initial_angle", 360.0, 1.5).as_relative()
	
	label.text = display_text

func set_text(text : String):
	label.text = text

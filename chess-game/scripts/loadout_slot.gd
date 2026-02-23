extends Control

@export var SAVE_STRING : String
@export var SLOT_NUM : int

@onready var LABEL = $Label

func _ready() -> void:
	SignalBus.loadout_button.connect(update_visuals)

func _on_texture_button_pressed() -> void:
	print("hi")
	SignalBus.emit_signal("loadout_button", SLOT_NUM)

func update_visuals(loadout):
	if loadout == SLOT_NUM:
		print("yay")
	else:
		print("booo")

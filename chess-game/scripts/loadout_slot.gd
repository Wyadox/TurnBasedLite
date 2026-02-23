extends Control

@export var SAVE_STRING : String
@export var SLOT_NUM : int

@onready var LABEL = $Label

func _ready() -> void:
	SignalBus.loadout_button.connect(update_visuals)
	
	if SLOT_NUM == 1:
		SAVE_STRING = LoadoutSaves.loadouts_to_save.loadout1
	elif SLOT_NUM == 2:
		SAVE_STRING = LoadoutSaves.loadouts_to_save.loadout2
	else:
		SAVE_STRING = LoadoutSaves.loadouts_to_save.loadout3

func _on_texture_button_pressed() -> void:
	SignalBus.emit_signal("loadout_button", SLOT_NUM)

func update_visuals(loadout):
	if loadout == SLOT_NUM:
		print("yay")
	else:
		print("booo")

extends Control

@export var SAVE_STRING : String
@export var SLOT_NUM : int

@onready var LABEL = $Label

var normal_tex = preload("res://Assets/Buttons/LoadoutButton.png")
var selected_tex = preload("res://Assets/Buttons/LoadoutButton_Selected.png")

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
		$TextureButton.texture_normal = selected_tex
	else:
		$TextureButton.texture_normal = normal_tex

func set_normal():
	$TextureButton.texture_normal = normal_tex

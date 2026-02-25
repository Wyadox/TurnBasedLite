extends Control

@onready var slot1 = $HBoxContainer/loadout_slot
@onready var slot2 = $HBoxContainer/loadout_slot2
@onready var slot3 = $HBoxContainer/loadout_slot3

func clear_selected():
	slot1.set_normal()
	slot2.set_normal()
	slot3.set_normal()

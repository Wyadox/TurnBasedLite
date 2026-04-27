extends Node

const SAVE_LOCATION = "res://Assets/Loadouts/Loadouts.json"


var loadouts_to_save : Dictionary = {
	"loadout1" : "4:0.0,5.0_",
	"loadout2" : "5:0.0,5.0_",
	"loadout3" : "6:0.0,5.0_",
}

func _ready() -> void:
	_load()

func _save():
	var file = FileAccess.open(SAVE_LOCATION, FileAccess.WRITE)
	file.store_var(loadouts_to_save.duplicate())
	file.close()
	
func _load():
	if FileAccess.file_exists(SAVE_LOCATION):
		var file = FileAccess.open(SAVE_LOCATION, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		var save_data = data.duplicate()
		loadouts_to_save.loadout1 = save_data.loadout1
		loadouts_to_save.loadout2 = save_data.loadout2
		loadouts_to_save.loadout3 = save_data.loadout3

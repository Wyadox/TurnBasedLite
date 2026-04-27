extends HSlider

@export var bus_name : Globals.VOLUME_BUSES

var bus_string
var bus_index

func _ready() -> void:
	match bus_name:
		Globals.VOLUME_BUSES.MASTER:
			bus_string = "Master"
		Globals.VOLUME_BUSES.MUSIC:
			bus_string = "Music"
		Globals.VOLUME_BUSES.SFX:
			bus_string = "SFX"
			
	bus_index = AudioServer.get_bus_index(bus_string)
	value_changed.connect(on_value_changed)
	
	value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)

func on_value_changed(num : float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(num)
	)
	match bus_name:
		Globals.VOLUME_BUSES.MASTER:
			SettingsManager.set_master(num)
		Globals.VOLUME_BUSES.MUSIC:
			SettingsManager.set_music(num)
		Globals.VOLUME_BUSES.SFX:
			SettingsManager.set_sfx(num)

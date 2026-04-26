extends Node

enum TOGGLES {
	TOOLTIPS,
	EVAL,
	PREVIOUS,
	LABELS,
	ANIMATIONS,
	PARTICLES
}

var settings_data : SettingsDataResource

var save_settings_path = "user://game_data"
var save_file_name = "settings_data.tres"

func _ready() -> void:
	load_settings()

func load_settings():
	if !DirAccess.dir_exists_absolute(save_settings_path):
		DirAccess.make_dir_absolute(save_settings_path)
	
	if ResourceLoader.exists(save_settings_path + save_file_name):
		settings_data = ResourceLoader.load(save_settings_path + save_file_name)
	
	if settings_data == null:
		settings_data = SettingsDataResource.new()
	
	if settings_data != null:
		set_window_mode(settings_data.window_mode, settings_data.window_mode_index)
		set_resolution(settings_data.resolution, settings_data.resolution_index)
		set_master(settings_data.master_value)
		set_music(settings_data.music_value)
		set_sfx(settings_data.sfx_value)
		
		Globals.show_tooltips = settings_data.show_tooltips

func set_window_mode(window_mode : int, window_mode_index : int):
	match window_mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	settings_data.window_mode = window_mode
	settings_data.window_mode_index = window_mode_index

func set_resolution(resolution : Vector2i, resolution_index : int):
	get_tree().root.content_scale_size = resolution
	settings_data.resolution = resolution
	settings_data.resolution_index = resolution_index

func set_master(master : float) -> void:
	AudioServer.set_bus_volume_db(
		0,
		linear_to_db(master)
	)
	settings_data.master_value = master

func set_music(music : float) -> void:
	AudioServer.set_bus_volume_db(
		1,
		linear_to_db(music)
	)
	settings_data.music_value = music

func set_sfx(sfx : float) -> void:
	AudioServer.set_bus_volume_db(
		2,
		linear_to_db(sfx)
	)
	settings_data.sfx_value = sfx

func get_settings() -> SettingsDataResource:
	return settings_data

func save_settings():
	ResourceSaver.save(settings_data, save_settings_path + save_file_name)

func set_toggle(type : TOGGLES, flag : bool):
	match type:
		TOGGLES.TOOLTIPS:
			settings_data.show_tooltips = flag
		TOGGLES.EVAL:
			settings_data.show_eval = flag
		TOGGLES.PREVIOUS:
			settings_data.show_previous = flag
		TOGGLES.LABELS:
			settings_data.show_labels = flag
		TOGGLES.ANIMATIONS:
			settings_data.play_animations = flag
		TOGGLES.PARTICLES:
			settings_data.play_particles = flag

func set_display_name(title : String) -> void:
	settings_data.display_name = title

func set_light_color(color : Color) -> void:
	settings_data.light_color = color

func set_dark_color(color : Color) -> void:
	settings_data.dark_color = color

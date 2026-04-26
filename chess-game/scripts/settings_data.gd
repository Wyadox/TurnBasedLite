extends Resource
class_name SettingsDataResource

@export var window_mode : int = 0
@export var window_mode_index : int = 0
@export var resolution : Vector2i = Vector2i(1920, 1080)
@export var resolution_index : int = 4

@export var master_value : float = 1.0
@export var music_value : float = 1.0
@export var sfx_value : float = 1.0

@export var show_tooltips : bool = true
@export var show_eval : bool = true
@export var show_previous : bool = true
@export var show_labels : bool = true
@export var play_animations : bool = true
@export var play_particles : bool = true

@export var light_color : Color = Color(0.8, 0.6, 0.4)
@export var dark_color : Color = Color(0.4, 0.3, 0.2)

@export var ai_time_limit : int = 2000

@export var display_name : String = "Chess Player"

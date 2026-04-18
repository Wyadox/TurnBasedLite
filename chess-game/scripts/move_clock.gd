extends Control

@onready var duration_timer: Timer = $Duration
#@onready var panel: Panel = $Panel
@onready var progress_bar: ProgressBar = $chess_background/MarginContainer/ProgressBar
@onready var label: Label = $chess_background/MarginContainer/Label

const PANEL_DEFAULT = preload("res://Assets/Themes/move_clock_default.tres")
const PANEL_CURRENT = preload("res://Assets/Themes/move_clock_current.tres")
const BAR_DEFAULT = preload("res://Assets/Themes/progress_bar_default.tres")
const BAR_CURRENT = preload("res://Assets/Themes/progress_bar_current.tres")

@export var duration : float = 3.0
@export var color : Globals.COLORS

func _ready() -> void:
	prime_clock()
	
func _process(_delta: float) -> void:
	progress_bar.value = duration_timer.time_left / (duration * 60)
	
	var total_seconds = int(duration_timer.time_left)
	var minutes = (total_seconds as float / 60) as int
	var seconds = total_seconds % 60
	label.text = "%d:%02d" % [minutes, seconds]
	
	if progress_bar.value == 0:
		SignalBus.move_clock_expired.emit()

func start_turn():
	duration_timer.paused = false
	#panel.add_theme_stylebox_override("panel", PANEL_CURRENT)
	progress_bar.add_theme_stylebox_override("fill", BAR_CURRENT)
	
func end_turn():
	duration_timer.paused = true
	#panel.add_theme_stylebox_override("panel", PANEL_DEFAULT)
	progress_bar.add_theme_stylebox_override("fill", BAR_DEFAULT)

func set_duration(minutes : float) -> void:
	duration = minutes
	prime_clock()

func prime_clock():
	duration_timer.wait_time = duration * 60
	duration_timer.start()
	duration_timer.paused = true

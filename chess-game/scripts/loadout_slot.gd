extends Control

@export var SAVE_STRING : String
@export var SLOT_NUM : int

@onready var LABEL = $Label

var normal_tex = preload("res://Assets/Buttons/LoadoutButtonNEW.png")
var selected_tex = preload("res://Assets/Buttons/LoadoutButtonNEW_SELECTED.png")

var label_default_pos : Vector2
const LABEL_OFFSET : Vector2 = Vector2(0, 6)

func _ready() -> void:
	SignalBus.loadout_button.connect(update_visuals)
	
	label_default_pos = LABEL.position
	LABEL.text = "LOADOUT " + str(SLOT_NUM)
	
	if SLOT_NUM == 1:
		SAVE_STRING = LoadoutSaves.loadouts_to_save.loadout1
	elif SLOT_NUM == 2:
		SAVE_STRING = LoadoutSaves.loadouts_to_save.loadout2
	else:
		SAVE_STRING = LoadoutSaves.loadouts_to_save.loadout3

func _on_texture_button_pressed() -> void:
	SignalBus.emit_signal("loadout_button", SLOT_NUM)
	
	var audioPlayer = AudioStreamPlayer2D.new()
	add_child(audioPlayer)
	audioPlayer.stream = preload("res://Assets/Sounds/button_click_cropped.mp3")
	audioPlayer.volume_db = linear_to_db(0.5)
	audioPlayer.play()
	audioPlayer.finished.connect(audioPlayer.queue_free)

func update_visuals(loadout):
	if loadout == SLOT_NUM:
		$TextureButton.texture_normal = selected_tex
	else:
		$TextureButton.texture_normal = normal_tex

func set_normal():
	$TextureButton.texture_normal = normal_tex


func _on_texture_button_mouse_exited() -> void:
	LABEL.position = label_default_pos


func _on_texture_button_button_up() -> void:
	LABEL.position = label_default_pos


func _on_texture_button_button_down() -> void:
	LABEL.position = label_default_pos + LABEL_OFFSET

extends Control

@onready var button: TextureButton = $Button
@onready var label: Label = $Label

@export var scene : PackedScene
@export var button_text : String
@export var quit_game : bool = false

const DELAY : float = 0.1

var label_default_pos : Vector2
var press_offset : Vector2 = Vector2(0, 6)
var cancel_function : bool = false

func _ready() -> void:
	label_default_pos = label.position
	label.text = button_text

func _on_button_button_up() -> void:
	label.position = label_default_pos
	if scene and !cancel_function:
		await get_tree().create_timer(DELAY).timeout
		get_tree().change_scene_to_packed(scene)
	if quit_game:
		get_tree().quit()

func _on_button_button_down() -> void:
	label.position = label_default_pos + press_offset
	print("hi")

func _on_button_mouse_entered() -> void:
	cancel_function = false
	print("enter")

func _on_button_mouse_exited() -> void:
	cancel_function = true
	
	label.position = label_default_pos
	print("exit")
	

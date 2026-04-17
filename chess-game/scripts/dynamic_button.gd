@tool
class_name DynamicButton
extends Control

signal button_triggered()

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var button: TextureButton = $Button
@onready var label: Label = $Label

@export var scene : PackedScene
@export var button_text : String
@export var quit_game : bool = false

@export var button_size : Vector2 = Vector2(64, 64) :
	set(value):
		if value < MINIMUM_SIZE:
			value = MINIMUM_SIZE
		button_size = value
		if is_node_ready():
			apply_size()

const DELAY : float = 0.1
const MINIMUM_SIZE : Vector2 = Vector2(64, 64)

const NORMAL_TEXTURE = preload("res://Assets/Buttons/BLANK_Button.png")
const HOVER_TEXTURE = preload("res://Assets/Buttons/BLANK_Button_Hover.png")
const PRESS_TEXTURE = preload("res://Assets/Buttons/BLANK_Button_Press.png")

var label_default_pos : Vector2
var press_offset : Vector2 = Vector2(0, 6)
var cancel_function : bool = false

func _ready() -> void:
	apply_size()
	label_default_pos = label.position
	print(label.position)
	label.text = button_text

func apply_size() -> void:
	custom_minimum_size = button_size
	size = button_size
	if button:
		button.size = button_size
	if nine_patch_rect:
		nine_patch_rect.size = button_size
	if label:
		label.position = Vector2.ZERO - press_offset
		label.size = button_size

func _on_button_button_up() -> void:
	label.position = label_default_pos
	print(label_default_pos)
	nine_patch_rect.texture = NORMAL_TEXTURE
	
	if !cancel_function:
		button_triggered.emit()
		if scene:
			await get_tree().create_timer(DELAY).timeout
			get_tree().change_scene_to_packed(scene)
	if quit_game:
		get_tree().quit()

func _on_button_button_down() -> void:
	label.position = label_default_pos + press_offset
	nine_patch_rect.texture = PRESS_TEXTURE
	
	print(label.position)
	print("hi")

func _on_button_mouse_entered() -> void:
	cancel_function = false
	nine_patch_rect.texture = HOVER_TEXTURE

func _on_button_mouse_exited() -> void:
	cancel_function = true
	nine_patch_rect.texture = NORMAL_TEXTURE
	label.position = label_default_pos
	print(label_default_pos)
	print("exit")
	

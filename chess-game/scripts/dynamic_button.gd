@tool
class_name DynamicButton
extends Control

signal button_triggered()

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var button: TextureButton = $Button
@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var margin_container: MarginContainer = $MarginContainer

@export var button_text : String
@export var quit_game : bool = false
@export var instant : bool = false
@export var image : Texture2D

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
const DISABLED_TEXTURE = preload("res://Assets/Buttons/BLANK_Button_Disabled.png")
const SELECTED_TEXTURE = preload("uid://bvtu2s2u6hpef")

var label_default_pos : Vector2
var press_offset : Vector2 = Vector2(0, 6)
var cancel_function : bool = false
var condition : bool = true
var selected : bool = false

func _ready() -> void:
	apply_size()
	texture_rect.texture = image
	label_default_pos = label.position
	label.text = button_text

func _process(_delta: float) -> void:
	texture_rect.position = label.position
	texture_rect.position += button_size / 2 - texture_rect.size / 2

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
	if margin_container:
		margin_container.size = button_size

func _on_button_button_up() -> void:
	label.position = label_default_pos
	if cancel_function:
		if selected:
			nine_patch_rect.texture = SELECTED_TEXTURE
		else:
			nine_patch_rect.texture = NORMAL_TEXTURE
	else:
		nine_patch_rect.texture = HOVER_TEXTURE
	
	var audioPlayer = AudioStreamPlayer2D.new()
	add_child(audioPlayer)
	audioPlayer.stream = preload("res://Assets/Sounds/button_click_cropped.mp3")
	audioPlayer.volume_db = linear_to_db(0.5)
	audioPlayer.play()
	audioPlayer.finished.connect(audioPlayer.queue_free)
	
	if instant:
		on_sound_complete()
	else:
		audioPlayer.finished.connect(on_sound_complete)

func on_sound_complete():
	button_triggered.emit()
	if quit_game:
		get_tree().quit()

func _on_button_button_down() -> void:
	label.position = label_default_pos + press_offset
	nine_patch_rect.texture = PRESS_TEXTURE

func _on_button_mouse_entered() -> void:
	cancel_function = false
	if !button.disabled:
		nine_patch_rect.texture = HOVER_TEXTURE

func _on_button_mouse_exited() -> void:
	cancel_function = true
	if button.disabled and !selected:
		nine_patch_rect.texture = DISABLED_TEXTURE
	elif selected:
		nine_patch_rect.texture = SELECTED_TEXTURE
	else:
		nine_patch_rect.texture = NORMAL_TEXTURE
	label.position = label_default_pos

func disable():
	button.disabled = true
	if selected:
		nine_patch_rect.texture = SELECTED_TEXTURE
	else:
		nine_patch_rect.texture = DISABLED_TEXTURE

func enable():
	button.disabled = false
	nine_patch_rect.texture = NORMAL_TEXTURE

func select():
	selected = true

func deselect():
	selected = false
	nine_patch_rect.texture = NORMAL_TEXTURE

func set_texture(texture : Texture2D):
	texture_rect.texture = texture
	if texture is AtlasTexture:
		texture_rect.custom_minimum_size = texture.region.size
	else:
		texture_rect.custom_minimum_size = texture.get_size()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

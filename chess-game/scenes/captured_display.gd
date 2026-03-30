extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer

@export var spritesheet : Texture2D
@export var color : Globals.COLORS

const SPRITE_SIZE = 32

func _ready() -> void:
	SignalBus.captured_piece.connect(add_piece)

func add_piece(colorCaptured : Globals.COLORS, piece_type: Globals.PIECE_TYPES):
	if colorCaptured != color:
		return
	
	var region_pos = Globals.SPRITE_MAPPING[color][piece_type]
	var region = Rect2(
		region_pos.y * SPRITE_SIZE,
		region_pos.x * SPRITE_SIZE,
		SPRITE_SIZE,
		SPRITE_SIZE
	)

	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = spritesheet
	atlas_texture.region = region

	var texture_rect = TextureRect.new()
	texture_rect.texture = atlas_texture
	texture_rect.custom_minimum_size = Vector2(SPRITE_SIZE, SPRITE_SIZE)
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	v_box_container.add_child(texture_rect)
	print("PIECE ADDED")

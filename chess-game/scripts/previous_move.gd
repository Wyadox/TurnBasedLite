extends Control

@onready var sprite = $Sprite2D
@onready var image : TextureRect = $Panel/image_preview
@onready var description_label = $Panel/Label

@export var color : Globals.COLORS

const SPRITE_SIZE = 32

var current_index = 0
var start_pos : Vector2
var end_pos : Vector2

var first_entry = true

func _ready():
	hide()
	
	SignalBus.previous_move.connect(process_previous_move)
	
func process_previous_move(piece_type : Globals.PIECE_TYPES, newColor : Globals.COLORS, old_pos : Vector2, new_pos : Vector2):
	show()
	
	if first_entry:
		first_entry = false
	else:
		SignalBus.archive_move.emit(current_index, color, start_pos, end_pos)
	
	current_index = piece_type
	color = newColor
	start_pos = old_pos
	end_pos = new_pos
	
	update_display()
	
func grab_region(piece_type):
	var region_pos = Globals.SPRITE_MAPPING[color][piece_type]
	var region = Rect2(
		region_pos.y * SPRITE_SIZE,
		region_pos.x * SPRITE_SIZE,
		SPRITE_SIZE,
		SPRITE_SIZE
	)
	
	var atlas := AtlasTexture.new()
	atlas.atlas = sprite.texture
	atlas.region = region
	
	return atlas
	
func update_display():
	var atlas = grab_region(current_index)
	image.texture = atlas
	description_label.text = str(start_pos + Vector2(1,1), " : ", end_pos + Vector2(1,1))

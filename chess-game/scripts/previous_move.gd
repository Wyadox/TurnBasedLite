extends Control

@onready var sprite = $Sprite2D
@onready var image : TextureRect = $Panel/image_preview
@onready var description_label = $Panel/Label

@export var color : Globals.COLORS

const SPRITE_SIZE = 32

var current_index = 0
var cloak = 0
var start_pos : Vector2
var end_pos : Vector2

var first_entry = true

func _ready():
	hide()
	
	SignalBus.previous_move.connect(process_previous_move)
	
func process_previous_move(piece_type : Globals.PIECE_TYPES, new_cloak : Globals.PIECE_TYPES, new_color : Globals.COLORS, old_pos : Vector2, new_pos : Vector2):
	show()
	
	if first_entry:
		first_entry = false
	else:
		SignalBus.archive_move.emit(current_index, new_cloak, color, start_pos, end_pos)
	
	current_index = piece_type
	cloak = new_cloak
	color = new_color
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
	var atlas = grab_region(cloak)
	image.texture = atlas
	
	var start_vector
	var end_vector
	start_vector = Globals.get_letters_for_history(start_pos)
	end_vector = Globals.get_letters_for_history(end_pos)
	description_label.text = str("(", start_vector[0] as String, ",", start_vector[1] as int, ") : (", end_vector[0] as String, ",", end_vector[1] as int, ")")

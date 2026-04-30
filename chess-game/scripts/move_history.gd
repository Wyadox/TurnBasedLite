extends Control

@onready var sprite = $Sprite2D
@onready var scroll_container: ScrollContainer = $chess_background/MarginContainer/ScrollContainer
@onready var v_box_container: VBoxContainer = $chess_background/MarginContainer/ScrollContainer/VBoxContainer

@export var color : Globals.COLORS

const SPRITE_SIZE = 32

var current_index = 0
var start_pos : Vector2
var end_pos : Vector2
var flip : bool = false

func _ready():
	hide()
	
	SignalBus.archive_move.connect(process_archive_move)
	
func process_archive_move(_piece_type : Globals.PIECE_TYPES, new_cloak : Globals.PIECE_TYPES, newColor : Globals.COLORS, old_pos : Vector2, new_pos : Vector2):
	show()
	
	color = newColor
	start_pos = old_pos
	end_pos = new_pos
	
	const ENTRY_SCENE = preload("res://scenes/move_history_entry.tscn")
	var move_entry = ENTRY_SCENE.instantiate()
	v_box_container.add_child(move_entry)
	v_box_container.move_child(move_entry, 0)
	move_entry.set_display(grab_region(new_cloak), get_label())
	
	await get_tree().process_frame
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().min_value as int
	
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
	
func get_label():
	var start_vector
	var end_vector
	start_vector = Globals.get_letters_for_history(start_pos)
	end_vector = Globals.get_letters_for_history(end_pos)
	if flip:
		start_vector = Globals.get_letters_for_history_inverted(start_pos)
		end_vector = Globals.get_letters_for_history_inverted(end_pos)
	return str("(", start_vector[0] as String, ",", start_vector[1] as int, ") : (", end_vector[0] as String, ",", end_vector[1] as int, ")")

extends Control

@onready var sprite = $Sprite2D
@onready var v_box_container: VBoxContainer = $Panel/ScrollContainer/VBoxContainer
@onready var scroll_container: ScrollContainer = $Panel/ScrollContainer

@export var color : Globals.COLORS

const SPRITE_SIZE = 32

var current_index = 0
var start_pos : Vector2
var end_pos : Vector2

func _ready():
	hide()
	
	SignalBus.archive_move.connect(process_archive_move)
	
func process_archive_move(piece_type : Globals.PIECE_TYPES, newColor : Globals.COLORS, old_pos : Vector2, new_pos : Vector2):
	show()
	
	color = newColor
	start_pos = old_pos
	end_pos = new_pos
	
	const ENTRY_SCENE = preload("res://scenes/move_history_entry.tscn")
	var move_entry = ENTRY_SCENE.instantiate()
	v_box_container.add_child(move_entry)
	v_box_container.move_child(move_entry, 0)
	move_entry.set_display(grab_region(piece_type), get_label())
	
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
	return str(start_pos + Vector2(1,1), " : ", end_pos + Vector2(1,1))

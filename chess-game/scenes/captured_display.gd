extends Control

@onready var sprite: Sprite2D = $Sprite2D
@onready var v_box_container: VBoxContainer = $VBoxContainer

@export var color : Globals.COLORS

const SPRITE_SIZE = 32

func add_piece(piece_type : Globals.PIECE_TYPES):
	if sprite:
		var region_pos = Globals.SPRITE_MAPPING[color][piece_type]
		sprite.region_rect = Rect2(
			region_pos.y * SPRITE_SIZE,
			region_pos.x * SPRITE_SIZE,
			SPRITE_SIZE,
			SPRITE_SIZE
		)
		var child : Rect2 = sprite.region_rect
		var new_sprite : Sprite2D = Sprite2D.new()
		new_sprite.texture = child
		v_box_container.add_child()

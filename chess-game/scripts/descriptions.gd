extends Control

@onready var sprite = $Sprite2D

var SPRITE_SIZE = 32

var items = [
	{"piece_type": Globals.PIECE_TYPES.HORSE_ARCHER, "description": "Archer - Based on the Knight, but this piece makes captures from a distance"},
	{"piece_type": Globals.PIECE_TYPES.ARCHBISHOP, "description": "Archbishop - Based on the Bishop, but this piece can switch diagonals"},
	{"piece_type": Globals.PIECE_TYPES.MITOSIS_PAWN, "description": "Mitosis - Based on the Pawn, but this piece can split into two regular pawns"},
	{"piece_type": Globals.PIECE_TYPES.SHIELD_KING, "description": "Shield King - Based on the King, but this piece protects any piece in a 3x3 area around it"},
	{"piece_type": Globals.PIECE_TYPES.DUCK, "description": "Duck - Based on the Queen, but this piece cannot capture nor can it be captured"},
	{"piece_type": Globals.PIECE_TYPES.WORM, "description": "Worm - Based on the Pawn, but this piece can wrap around the sides of the board"},
	{"piece_type": Globals.PIECE_TYPES.CHECKER, "description": "Checker - Based on the Pawn, but this piece jumps over pieces to capture them and after a capture you get to move again"},
	{"piece_type": Globals.PIECE_TYPES.EXPLODING_BISHOP, "description": "Exploding Bishop - Based on the Bishop, but this piece explodes when captured or when capturing"},
	{"piece_type": Globals.PIECE_TYPES.ACROBISHOP, "description": "Acrobishop - Based on the Bishop, but can jump over pieces and is limited to moving 2 squares on any diagonal"},
	{"piece_type": Globals.PIECE_TYPES.JOUST_BISHOP, "description": "Jouster - Based on the Bishop, but when this piece captures it will capture any piece directly behind it and when captured the opposing piece is also captured."},
	{"piece_type": Globals.PIECE_TYPES.STUN_KNIGHT, "description": "Stun Knight - Based on the Knight, but when this piece is moved any opposing piece in orthogonal squares are stunned for one turn."},
	{"piece_type": Globals.PIECE_TYPES.TROJAN_HORSE, "description": "Trojan Horse - Based on the Knight, but when this piece is captured two pawns are spawned."},
	{"piece_type": Globals.PIECE_TYPES.GUARDIAN_ANGEL, "description": "Guardian Angel - The Guardian Angel may move one space in any direction, though it may also swap positions with another friendly piece."},
	{"piece_type": Globals.PIECE_TYPES.SUMO, "description": "Sumo - Based on the Rook, but the Sumo may also use its move to throw adjacent pieces to another square. If that square is an occupied square, both pieces are captured."},
	{"piece_type": Globals.PIECE_TYPES.MAGMA_KNIGHT, "description": "Magma Knight - Based on the Knight, but leaves an impassable magma tile that lasts for 3 turns when it leaves a tile."},
	{"piece_type": Globals.PIECE_TYPES.DUPLICATOR, "description": "Duplicator - Based on the Pawn, but can select an adjacent friendly piece and become a copy of that piece for the rest of the game."},
	{"piece_type": Globals.PIECE_TYPES.WARHORSE, "description": "Warhorse - Based on the Knight, but can only move every other turn. In exchange, when it captures, it captures all pieces adjacent to its target as well."},
	{"piece_type": Globals.PIECE_TYPES.INFECTOR, "description": "Infector - Based on the Pawn, but it infects pieces instead of captures. Infected pieces are stunned for their controller's next turn, then become a piece of the other color."},
	{"piece_type": Globals.PIECE_TYPES.JUGGERNAUT, "description": "Juggernaut - Based on the King, but it must be captured 3 times to be captured."},
	{"piece_type": Globals.PIECE_TYPES.WIZARD, "description": "Wizard - The Wizard is a special piece with 2 spells on cooldown timers. Moving vertically, cast a fireball that travels across the board and destroys a piece on that file. Moving horizontally, teleport to any square on the rank."}
	]

var current_index = 0

@onready var image : TextureRect = $Panel/image_preview
@onready var description_label = $Panel/Label
@onready var left_button = $Panel/Left_Button
@onready var right_button = $Panel/Right_Button

var selected_pos

func _ready():
	update_display()
	
	#SignalBus.selected_square.connect(set_selected_square)
	
func set_selected_square(pos):
	selected_pos = pos
	print("descriptions set pos: ", selected_pos)
	
func grab_region(piece_type):
	var region_pos = Globals.SPRITE_MAPPING[Globals.COLORS.WHITE][piece_type]
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
	var item = items[current_index]
	var atlas = grab_region(item.piece_type)
	image.texture = atlas
	description_label.text = items[current_index]["description"]

func _on_left_button_pressed() -> void:
	current_index = (current_index - 1) % items.size()
	update_display()


func _on_right_button_pressed() -> void:
	current_index = (current_index + 1) % items.size()
	update_display()


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_spawn_button_pressed() -> void:
	#SignalBus.selected_square.emit(selected_pos)
	SignalBus.setup_piece_by_type.emit(items[current_index]["piece_type"])
	print("spawn button emitted: ", str(items[current_index]["piece_type"]))

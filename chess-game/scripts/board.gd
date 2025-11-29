extends Node2D

signal setup_complete
signal set_status(color)

@export var pieces = [];
@export var piece_scene = preload("res://scenes/Piece.tscn")
@export var game_script = preload("res://scripts/game.gd")

@export var white_king_pos: Vector2
@export var black_king_pos: Vector2

var selected_pos: Vector2 = Vector2(-1, -1)
var setup_done: bool = false

const CELL_SIZE = 120

# Called when the node enters the scene tree for the first time.
func _ready():
	draw_board()
	init_pieces()

func draw_board():
	for x in range(6):
		for y in range(6):
			draw_cell(x, y)

func draw_cell(x, y):
	var rect = ColorRect.new()
	rect.color = Color(0.8, 0.6, 0.4) if (x + y) % 2 == 0 else Color(0.4, 0.3, 0.2)
	rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	rect.position = Vector2(
		x * CELL_SIZE,
		y * CELL_SIZE
	)
	rect.z_index = -100
	add_child(rect)

func init_pieces():
	for piece_tuple in Globals.INITIAL_PIECE_SET_SINGLE:
		var piece_type = piece_tuple[0]
		var black_piece_pos = Vector2(piece_tuple[1], piece_tuple[2])
		var white_piece_pos = Vector2(piece_tuple[1], 6 -  1 - piece_tuple[2])
		
		# Create black piece
		var black_piece = piece_scene.instantiate()
		add_child(black_piece)
		black_piece.init_piece(
			piece_type,
			Globals.COLORS.BLACK,
			black_piece_pos,
			self
		)
		pieces.append(black_piece)
		
		# Create white piece
		var white_piece = piece_scene.instantiate()
		add_child(white_piece)
		white_piece.init_piece(
			piece_type,
			Globals.COLORS.WHITE,
			white_piece_pos,
			self
		)
		pieces.append(white_piece)
		
		if piece_type == Globals.PIECE_TYPES.KING:
			register_king(white_piece_pos, Globals.COLORS.WHITE)
			register_king(black_piece_pos, Globals.COLORS.BLACK)

func register_king(pos, col):
	match col:
		Globals.COLORS.WHITE:
			white_king_pos = pos
		Globals.COLORS.BLACK:
			black_king_pos = pos

func get_piece(pos: Vector2):
	if pieces.size() < 1:
		return
	for piece in pieces:
		if piece.board_position == pos:
			return piece

func delete_piece(piece):
	for i in range(len(pieces)):
		if pieces[i] == piece:
			var popped = pieces.pop_at(i)
			popped.queue_free()
			return

func beam_search_threat(own_color, cur_x, cur_y, inc_x, inc_y):
	# Moves a pointer in a line in given inc_x/y direction
	# to find the thratened pieces
	var threat_pos = []
	
	cur_x += inc_x
	cur_y += inc_y
	
	# Keep moving in increment direction to find either a blocked pieces
	# or out of board
	while cur_x >= 0 and cur_x < 6 and cur_y >= 0 and cur_y < 6:
		var cur_pos = Vector2(cur_x, cur_y)
		var cur_piece = get_piece(cur_pos)
		if cur_piece != null:
			if cur_piece.color != own_color:
				threat_pos.append(cur_pos)
			break
		threat_pos.append(cur_pos)
		cur_x += inc_x
		cur_y += inc_y
	
	return threat_pos

func spot_search_threat(
	own_color, 
	cur_x, cur_y, 
	inc_x, inc_y,
	threat_only = false, free_only = false
):
	# Do a single move and check if move is valid or threatens a piece
	cur_x += inc_x
	cur_y += inc_y
	
	if cur_x >= 6 or cur_x < 0 or cur_y >= 6 or cur_y < 0:
		return
	
	var cur_pos = Vector2(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	if cur_piece != null:
		if free_only:
			return
		return cur_pos if cur_piece.color != own_color else null
	return cur_pos if not threat_only else null

func clone():
	var board = self.duplicate()
	for i in range(len(pieces)):
		var piece = pieces[i].clone(board)
		board.pieces[i] = piece
	return board
	
func is_within_bounds(pos: Vector2):
	return pos.x >= 0 and pos.x < 6 and pos.y >= 0 and pos.y < 6

func create_piece(type: Globals.PIECE_TYPES, col: Globals.COLORS, board_pos: Vector2):
	var piece = piece_scene.instantiate()
	add_child(piece)
	piece.init_piece(type, col, board_pos, self)
	pieces.append(piece)
	return piece

var border_panel

func _on_setup_phase_ui_spawn_piece(piece_type: Variant) -> void:
	if selected_pos == Vector2(-1, -1):
		print("Select a valid position")
		return
	
	if setup_done == true:
		print("Setup phase is over")
		return
		
	# Determine color for current piece
	var color
	var total_pieces : int = num_pieces()
	if total_pieces < 6:
		color = Globals.COLORS.WHITE
	else:
		color = Globals.COLORS.BLACK
	create_piece(piece_type, color, selected_pos)
	
	# Determine if color needs to swap
	if total_pieces + 1 < 6:
		color = Globals.COLORS.WHITE
	else:
		color = Globals.COLORS.BLACK
	emit_signal("set_status", color)
	
	# Ready to play
	if total_pieces + 1 > 11:
		setup_done = true
		emit_signal("setup_complete")
		
	# Reset border visual and selected pos
	if border_panel and border_panel.is_inside_tree():
		border_panel.queue_free()
	selected_pos = Vector2(-1, -1)


func _on_game_selected_square(pos: Variant) -> void:
	selected_pos = pos
	print(pos)
	draw_border(pos.x, pos.y)
	
func draw_border(x, y):
	if border_panel and border_panel.is_inside_tree():
		border_panel.queue_free()
	border_panel = Panel.new()
	border_panel.size = Vector2(CELL_SIZE, CELL_SIZE)
	border_panel.position = Vector2(
		x * CELL_SIZE,
		y * CELL_SIZE
	)
	border_panel.z_index = 100
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = Color(0.0, 0.0, 1.0)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	border_panel.add_theme_stylebox_override("panel", style)
	
	add_child(border_panel)
	
func num_pieces():
	var count : int = 0
	for piece in pieces:
		count += 1
	return count

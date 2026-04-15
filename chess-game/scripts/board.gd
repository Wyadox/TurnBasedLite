class_name Board
extends Node2D

@export var pieces = []
@export var piece_scene = preload("res://scenes/Piece.tscn")
@export var setup_script = preload("res://scripts/setup_phase_ui.gd")
@export var status_indicator = preload("res://scenes/StatusIndicator.tscn")
const TILE_MAP = preload("res://tileMap.png")

var bridge_left: Texture2D = preload("res://Assets/bridgeLeft.png")
var bridge_mid: Texture2D = preload("res://Assets/bridgeMid.png")
var bridge_right: Texture2D = preload("res://Assets/bridgeRight.png")
var bridge_full: Texture2D = preload("res://Assets/bridgeFull.png")

var shield_king = []
@export var white_king_pos: Vector2 = Vector2(-2, -2)
@export var black_king_pos: Vector2 = Vector2(-2, -2)

var selected_pos: Vector2 = Vector2(-1, -1)
var setup_done: bool = false

var real_board : bool = true

enum BOARD_TYPE {
	STANDARD,
	RIVER,
	FOREST,
	WALL
}
var selected_board: BOARD_TYPE = BOARD_TYPE.STANDARD
const CELL_SIZE = 120

const BOARD_HEIGHT = 7
const BOARD_WIDTH = 7
const GAME_X_OFFSET = 1
const GAME_Y_OFFSET = 1

var is_loadout_board : bool = false

var first_color : Globals.COLORS
var second_color : Globals.COLORS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	draw_board()
	if selected_board == BOARD_TYPE.RIVER:
		draw_river()
	elif selected_board == BOARD_TYPE.FOREST:
		draw_forest()
	elif selected_board == BOARD_TYPE.WALL:
		draw_wall()
	clear_borders()
	
	SignalBus.spawn_piece.connect(_on_setup_phase_ui_spawn_piece)
	SignalBus.init_ai.connect(_on_game_init_ai)
	SignalBus.selected_square.connect(_on_game_selected_square)
	
	SignalBus.change_map.connect(_on_set_board_type)

func draw_board():
	if !is_loadout_board:
		for x in range(BOARD_WIDTH):
			for y in range(BOARD_HEIGHT):
				draw_cell(x, y)
	else:
		for x in range(BOARD_WIDTH):
			for y in range(2):
				draw_cell(x, y)
				
func _on_set_board_type(current_map):
	
	if current_map == 1:
		selected_board = BOARD_TYPE.STANDARD
		draw_board()
	elif current_map == 2:
		selected_board = BOARD_TYPE.RIVER
		draw_board()
		if selected_board == BOARD_TYPE.RIVER:
			draw_river()
	elif current_map == 3:
		selected_board = BOARD_TYPE.FOREST
		draw_board()
		if selected_board == BOARD_TYPE.FOREST:
			draw_forest()
	elif current_map == 4:
		selected_board = BOARD_TYPE.WALL
		draw_board()
		if selected_board == BOARD_TYPE.WALL:
			draw_wall()
				
func draw_river():
	draw_bridge(bridge_right, 0, 2)
	draw_bridge(bridge_right, 0, 3)
	draw_bridge(bridge_right, 0, 4)
	#create_piece(Globals.PIECE_TYPES.BRIDGE_RIGHT, Globals.COLORS.TILE, Vector2(0,2))
	#create_piece(Globals.PIECE_TYPES.BRIDGE_RIGHT, Globals.COLORS.TILE, Vector2(0,3))
	#create_piece(Globals.PIECE_TYPES.BRIDGE_RIGHT, Globals.COLORS.TILE, Vector2(0,4))
	create_piece(Globals.PIECE_TYPES.WATER, Globals.COLORS.TILE, Vector2(1,2))
	draw_bridge(bridge_mid, 1, 3)
	#create_piece(Globals.PIECE_TYPES.BRIDGE_MID, Globals.COLORS.TILE, Vector2(1,3))
	create_piece(Globals.PIECE_TYPES.WATER, Globals.COLORS.TILE, Vector2(1,4))
	create_piece(Globals.PIECE_TYPES.WATER, Globals.COLORS.TILE, Vector2(2,2))
	create_piece(Globals.PIECE_TYPES.WATER, Globals.COLORS.TILE, Vector2(2,3))
	create_piece(Globals.PIECE_TYPES.WATER, Globals.COLORS.TILE, Vector2(2,4))
	draw_bridge(bridge_full, 3, 2)
	draw_bridge(bridge_full, 3, 3)
	draw_bridge(bridge_full, 3, 4)
	#create_piece(Globals.PIECE_TYPES.BRIDGE_FULL, Globals.COLORS.TILE, Vector2(3,2))
	#create_piece(Globals.PIECE_TYPES.BRIDGE_FULL, Globals.COLORS.TILE, Vector2(3,3))
	#create_piece(Globals.PIECE_TYPES.BRIDGE_FULL, Globals.COLORS.TILE, Vector2(3,4))
	create_piece(Globals.PIECE_TYPES.WATER, Globals.COLORS.TILE, Vector2(4,3))
	create_piece(Globals.PIECE_TYPES.WATER, Globals.COLORS.TILE, Vector2(4,4))
	create_piece(Globals.PIECE_TYPES.WATER, Globals.COLORS.TILE, Vector2(4,2))
	create_piece(Globals.PIECE_TYPES.WATER, Globals.COLORS.TILE, Vector2(5,2))
	draw_bridge(bridge_mid, 5, 3)
	#create_piece(Globals.PIECE_TYPES.BRIDGE_MID, Globals.COLORS.TILE, Vector2(5,3))
	create_piece(Globals.PIECE_TYPES.WATER, Globals.COLORS.TILE, Vector2(5,4))
	draw_bridge(bridge_left, 6, 2)
	draw_bridge(bridge_left, 6, 3)
	draw_bridge(bridge_left, 6, 4)
	#create_piece(Globals.PIECE_TYPES.BRIDGE_LEFT, Globals.COLORS.TILE, Vector2(6,2))
	#create_piece(Globals.PIECE_TYPES.BRIDGE_LEFT, Globals.COLORS.TILE, Vector2(6,3))
	#create_piece(Globals.PIECE_TYPES.BRIDGE_LEFT, Globals.COLORS.TILE, Vector2(6,4))
	
	
	for i in range(7):
		for j in range(7):
			var piece = get_piece(Vector2(i,j))
			if piece != null and piece.color != Globals.COLORS.BLACK and piece.color != Globals.COLORS.WHITE:
				piece.scale *= 1.25
	
	
func draw_forest():
	create_piece(Globals.PIECE_TYPES.WEB, Globals.COLORS.TILE, Vector2(0,2))
	create_piece(Globals.PIECE_TYPES.TREE, Globals.COLORS.TILE, Vector2(0,4))
	create_piece(Globals.PIECE_TYPES.TREE, Globals.COLORS.TILE, Vector2(1,2))
	create_piece(Globals.PIECE_TYPES.WEB, Globals.COLORS.TILE, Vector2(1,4))
	create_piece(Globals.PIECE_TYPES.TREE, Globals.COLORS.TILE, Vector2(2,4))
	create_piece(Globals.PIECE_TYPES.WEB, Globals.COLORS.TILE, Vector2(3,3))
	create_piece(Globals.PIECE_TYPES.TREE, Globals.COLORS.TILE, Vector2(4,2))
	create_piece(Globals.PIECE_TYPES.WEB, Globals.COLORS.TILE, Vector2(5,2))
	create_piece(Globals.PIECE_TYPES.TREE, Globals.COLORS.TILE, Vector2(5,4))
	create_piece(Globals.PIECE_TYPES.TREE, Globals.COLORS.TILE, Vector2(6,2))
	create_piece(Globals.PIECE_TYPES.WEB, Globals.COLORS.TILE, Vector2(6,4))
	
	for i in range(7):
		for j in range(7):
			var piece = get_piece(Vector2(i,j))
			if piece != null and piece.color != Globals.COLORS.BLACK and piece.color != Globals.COLORS.WHITE:
				piece.scale *= 1.25

func draw_wall():
	create_piece(Globals.PIECE_TYPES.BRICKS, Globals.COLORS.TILE, Vector2(0,2))
	create_piece(Globals.PIECE_TYPES.MAGMA_MED, Globals.COLORS.TILE, Vector2(0,3))
	var magma = get_piece(Vector2(0, 3))
	magma.cool_counter = 4
	create_piece(Globals.PIECE_TYPES.BRICKS, Globals.COLORS.TILE, Vector2(1,3))
	create_piece(Globals.PIECE_TYPES.BRICKS, Globals.COLORS.TILE, Vector2(2,3))
	create_piece(Globals.PIECE_TYPES.MAGMA_LOW, Globals.COLORS.TILE, Vector2(3,3))
	magma = get_piece(Vector2(3, 3))
	magma.cool_counter = 2
	create_piece(Globals.PIECE_TYPES.BRICKS, Globals.COLORS.TILE, Vector2(4,3))
	create_piece(Globals.PIECE_TYPES.BRICKS, Globals.COLORS.TILE, Vector2(5,3))
	create_piece(Globals.PIECE_TYPES.MAGMA_MED, Globals.COLORS.TILE, Vector2(6,3))
	magma = get_piece(Vector2(6, 3))
	magma.cool_counter = 4
	create_piece(Globals.PIECE_TYPES.BRICKS, Globals.COLORS.TILE, Vector2(6,4))
	
	for i in range(7):
		for j in range(7):
			var piece = get_piece(Vector2(i,j))
			if piece != null and piece.color != Globals.COLORS.BLACK and piece.color != Globals.COLORS.WHITE:
				piece.scale *= 1.25

func draw_cell(x, y):
	var rect = ColorRect.new()
	if selected_board == BOARD_TYPE.STANDARD:
		rect.color = Color(0.8, 0.6, 0.4) if (x + y) % 2 == 0 else Color(0.4, 0.3, 0.2)
	elif selected_board == BOARD_TYPE.RIVER:
		rect.color = Color(0.378, 0.586, 1.0, 1.0) if (x + y) % 2 == 0 else Color(0.177, 0.306, 1.0, 1.0)
	elif selected_board == BOARD_TYPE.FOREST:
		rect.color = Color(0.546, 0.744, 0.499, 1.0) if (x + y) % 2 == 0 else Color(0.157, 0.346, 0.185, 1.0)
	elif selected_board == BOARD_TYPE.WALL:
		rect.color = Color(0.955, 0.761, 0.361, 1.0) if (x + y) % 2 == 0 else Color(0.295, 0.217, 0.139, 1.0)
	rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	rect.position = Vector2(
		x * CELL_SIZE,
		y * CELL_SIZE
	)
	rect.z_index = -100
	add_child(rect)

func draw_bridge(texture, x, y):
	var rect = TextureRect.new()
	rect.texture = texture
	rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	rect.position = Vector2(
		x * CELL_SIZE,
		y * CELL_SIZE
	)
	rect.z_index = -100
	add_child(rect)
	
func draw_water(x,y):
	var rect = ColorRect.new()
	rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	

func register_king():
	for piece in pieces:
		if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
			shield_king.append(piece)

func get_piece(pos: Vector2):
	if pieces.size() < 1:
		return
	for piece in pieces:
		if piece and piece.board_position == pos:
			return piece
			
func play_sound(title : String):
	var audioPlayer = AudioStreamPlayer2D.new()
	add_child(audioPlayer)
	
	match title:
		"move" : audioPlayer.stream = preload("res://Assets/Sounds/move-self.mp3")
		"capture" : audioPlayer.stream = preload("res://Assets/Sounds/capture.mp3")
		"promote" : audioPlayer.stream = preload("res://Assets/Sounds/promote.mp3")
		"check" : audioPlayer.stream = preload("res://Assets/Sounds/move-check.mp3")
		"castle" : audioPlayer.stream = preload("res://Assets/Sounds/castle.mp3")
		"explosion" : audioPlayer.stream = preload("res://Assets/Sounds/explosion.wav")
	
	audioPlayer.play()
	audioPlayer.finished.connect(audioPlayer.queue_free)

func on_capture(dest_piece, selected_piece, board, previous_position):
	if selected_piece == null:
		return
	if dest_piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
		for king in shield_king:
			if king == dest_piece:
				shield_king.erase(king)
	if dest_piece.piece_type == Globals.PIECE_TYPES.WEB and selected_piece.piece_type != Globals.PIECE_TYPES.HORSE_ARCHER:
		selected_piece.stun_counter = 3
	if dest_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP:
		ExplodingBishop.explode_piece(dest_piece, selected_piece, board)
		delete_piece(selected_piece)
	elif selected_piece.piece_type == Globals.PIECE_TYPES.INFECTOR and dest_piece.piece_type != Globals.PIECE_TYPES.WEB:
		Infector.InfectPiece(dest_piece)
		return
	elif dest_piece.piece_type == Globals.PIECE_TYPES.TROJAN_HORSE:
		TrojanHorse.trojan_spawn(dest_piece, board)
		delete_piece(dest_piece)
	elif dest_piece.piece_type == Globals.PIECE_TYPES.JUGGERNAUT or dest_piece.piece_type == Globals.PIECE_TYPES.JUGGERNAUT2:
		Juggernaut.JuggernautUpdate(board, dest_piece)
		return
		
	
	if real_board:
		if dest_piece.board_position.x > previous_position.x:
			play_animation(dest_piece, "capture_right")
		else:
			play_animation(dest_piece, "capture_left")
		play_sound("capture")
		SignalBus.captured_piece.emit(dest_piece.color, dest_piece.piece_type)
	
	delete_piece(dest_piece)
	
func delete_piece(piece, force = false):
	for i in range(len(pieces)):
		if pieces[i] == piece && (piece_is_protected(piece) == false or force):
			var popped = pieces.pop_at(i)
			popped.queue_free()
			return

#
# LOOK HERE if there are issues with piece evaluation inconsistencies 
#
func play_animation(piece, anim_name : String) -> void:
	if real_board:
		var animation_piece = piece_scene.instantiate()
		add_child(animation_piece)
		animation_piece.init_piece(piece.piece_type, piece.color, piece.board_position, self)
		animation_piece.global_position = piece.global_position
		animation_piece.play_animation(anim_name)
		await animation_piece.animation_player.animation_finished
		animation_piece.queue_free()
			
func wipe_pieces(if_white = true, if_black = true):
	var pieces_to_remove = []
	for piece in pieces:
		if (if_white and piece.color == Globals.COLORS.WHITE) or (if_black and piece.color == Globals.COLORS.BLACK):
			pieces_to_remove.append(piece)
	
	for piece in pieces_to_remove:
		piece.queue_free()
		pieces.erase(piece)

func beam_search_threat(own_color, cur_x, cur_y, inc_x, inc_y):
	# Moves a pointer in a line in given inc_x/y direction
	# to find the thratened pieces
	var threat_pos = []
	var is_duck = false
	
	var check_piece = get_piece(Vector2(cur_x, cur_y))
	if check_piece.piece_type == Globals.PIECE_TYPES.DUCK:
		is_duck = true
	
	cur_x += inc_x
	cur_y += inc_y
	
	# Keep moving in increment direction to find either a blocked pieces
	# or out of board
	while is_within_bounds(Vector2(cur_x, cur_y)):
		var cur_pos = Vector2(cur_x, cur_y)
		var cur_piece = get_piece(cur_pos)
		if cur_piece != null:
			if cur_piece.color != own_color and cur_piece.piece_type != Globals.PIECE_TYPES.DUCK and !is_duck:
				threat_pos.append(cur_pos)
			elif is_duck and cur_piece.piece_type == Globals.PIECE_TYPES.WEB:
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
	
	if !is_within_bounds(Vector2(cur_x, cur_y)):
		return
	
	var cur_pos = Vector2(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	#if cur_piece != null and cur_piece.piece_type == Globals.PIECE_TYPES.DUCK:
		#return null
	
	if cur_piece != null:
		if free_only:
			return
		return cur_pos if cur_piece.color != own_color else null
	return cur_pos if not threat_only else null
	
func spot_search_duplicate(
	own_color, 
	cur_x, cur_y, 
	inc_x, inc_y,
):
	# Do a single move and check if move is valid or threatens a piece
	cur_x += inc_x
	cur_y += inc_y
	
	if !is_within_bounds(Vector2(cur_x, cur_y)):
		return
	
	var cur_pos = Vector2(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	#if cur_piece != null and cur_piece.piece_type == Globals.PIECE_TYPES.DUCK:
		#return null
	
	if cur_piece != null:
		return cur_pos if cur_piece.color == own_color else null
		
func spot_search_guardian(
	own_color, 
	target_x, target_y
):
	# Do a single move and check if move is valid or threatens a piece
	
	if !is_within_bounds(Vector2(target_x, target_y)):
		return
	
	var cur_pos = Vector2(target_x, target_y)
	var cur_piece = get_piece(cur_pos)
	
	#if cur_piece != null and cur_piece.piece_type == Globals.PIECE_TYPES.DUCK:
		#return null
	
	if cur_piece != null:
		return cur_pos if cur_piece.color == own_color else null
	
func spot_search_explode( 
	cur_x, cur_y, 
	inc_x, inc_y,
	threat_only = false, free_only = false
):
	# Do a single move and check if move is valid or threatens a piece
	cur_x += inc_x
	cur_y += inc_y
	
	if !is_within_bounds(Vector2(cur_x, cur_y)):
		return
	
	var cur_pos = Vector2(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	if cur_piece != null:
		if free_only:
			return
	return cur_pos if not threat_only else null
	
func spot_search_protect(
	own_color, 
	cur_x, cur_y, 
	inc_x, inc_y,
	threat_only = false, free_only = false
):
	# Do a single move and check if move is valid or threatens a piece
	cur_x += inc_x
	cur_y += inc_y
	
	if !is_within_bounds(Vector2(cur_x, cur_y)):
		return
	
	var cur_pos = Vector2(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	if cur_piece != null:
		if free_only:
			return
		return cur_pos if cur_piece.color == own_color else null
	return cur_pos if not threat_only else null

func clone():
	var board = self.duplicate()
	for i in range(len(pieces)):
		var piece = pieces[i].clone(board)
		board.pieces[i] = piece
	return board
	
func is_within_bounds(pos: Vector2):
	return pos.x >= 0 and pos.x < BOARD_WIDTH and pos.y >= 0 and pos.y < BOARD_HEIGHT

func create_piece(type: Globals.PIECE_TYPES, col: Globals.COLORS, board_pos: Vector2):
	var piece = piece_scene.instantiate()
	add_child(piece)
	piece.init_piece(type, col, board_pos, self)
	pieces.append(piece)
	return piece

var border_shape
var borders = []

func _on_setup_phase_ui_spawn_piece(piece_type: Globals.PIECE_TYPES) -> void:
	print("hi from spawn piece")
	if selected_pos == Vector2(-1, -1) or !is_within_bounds(selected_pos):
		if is_loadout_board:
			selected_pos = find_viable_square()
			if selected_pos == Vector2(-1, -1) or !is_within_bounds(selected_pos):
				SignalBus.emit_signal("refund_piece", piece_type)
				return
		else:
			SignalBus.emit_signal("refund_piece", piece_type)
			return
	
	if setup_done == true:
		return
		
	# Determine color for current piece
	var color
	var total_pieces : int = num_pieces()
	if total_pieces < Globals.PIECES_PER_SIDE:
		color = Globals.COLORS.WHITE
	elif !is_loadout_board:
		color = Globals.COLORS.BLACK
	create_piece(piece_type, color, selected_pos)
	
	# Determine if color needs to swap
	if total_pieces + 1 < Globals.PIECES_PER_SIDE or total_pieces > (Globals.PIECES_PER_SIDE - 1) * 2:
		color = Globals.COLORS.WHITE
	elif !is_loadout_board:
		color = Globals.COLORS.BLACK
	SignalBus.emit_signal("set_status", color)
	
	if total_pieces == Globals.PIECES_PER_SIDE - 1:
		SignalBus.emit_signal("spawn_ai")
		total_pieces = num_pieces()
	
	# Ready to play
	if total_pieces > (Globals.PIECES_PER_SIDE - 1) * 2:
		setup_done = true
		SignalBus.emit_signal("setup_complete")
		
	# Reset border visual and selected pos
	if border_shape and border_shape.is_inside_tree():
		border_shape.queue_free()
	selected_pos = Vector2(-1, -1)

func find_viable_square() -> Vector2:
	var flag : bool = true
	var flag_flip_count : int = 0
	for i in range(Board.BOARD_WIDTH):
		for j in range(2):
			flag = true
			for piece in pieces:
				if piece.board_position == Vector2(i,j):
					flag = false
					flag_flip_count += 1
			if flag:
				return Vector2(i,j)
			if flag_flip_count >= Globals.PIECES_PER_SIDE:
				return Vector2(-1, -1)
	return Vector2(-1, -1)

func _on_game_selected_square(pos: Vector2) -> void:
	selected_pos = pos
	if !is_within_bounds(selected_pos):
		if border_shape:
			border_shape.queue_free()
		return
	
	if is_loadout_board:
		draw_border(pos.x, pos.y, Color(0.0, 1.0, 0.38, 1.0), true, Globals.BORDER_STYLE.BOX)
	else:
		draw_border(pos.x, pos.y, Color(0.0, 0.0, 1.0, 1.0), true, Globals.BORDER_STYLE.BOX)
	
func draw_border(x, y, color, clear, border_style : Globals.BORDER_STYLE):
	if clear and border_shape and border_shape.is_inside_tree():
		border_shape.queue_free()
	
	var pos = Vector2(
		x * CELL_SIZE,
		y * CELL_SIZE
	)
		
	match border_style:
		Globals.BORDER_STYLE.BOX:
			border_shape = Panel.new()
			border_shape.size = Vector2(CELL_SIZE, CELL_SIZE)
			border_shape.position = pos
			border_shape.z_index = 50
			
			var style := StyleBoxFlat.new()
			style.bg_color = Color.TRANSPARENT
			style.border_color = color
			style.border_width_left = 4
			style.border_width_top = 4
			style.border_width_right = 4
			style.border_width_bottom = 4
			border_shape.add_theme_stylebox_override("panel", style)
			
			add_child(border_shape)
		Globals.BORDER_STYLE.CIRCLE:
			var circle = Circle.new()
			circle.size = Vector2(CELL_SIZE, CELL_SIZE)
			circle.position = pos
			circle.color = color
			circle.radius = CELL_SIZE as float / 2 - 40
			circle.z_index = 50
			
			border_shape = circle
			add_child(circle)
		Globals.BORDER_STYLE.TARGET:
			var target = Target.new()
			target.size = Vector2(CELL_SIZE, CELL_SIZE)
			target.position = pos
			target.color = color
			target.radius = CELL_SIZE as float / 2 - 4
			target.z_index = 50
			
			border_shape = target
			add_child(target)
		Globals.BORDER_STYLE.HIGHLIGHT:
			border_shape = Panel.new()
			border_shape.size = Vector2(CELL_SIZE, CELL_SIZE)
			border_shape.position = pos
			border_shape.z_index = 20
			
			var style := StyleBoxFlat.new()
			style.bg_color = color
			style.border_color = color
			style.border_width_left = 4
			style.border_width_top = 4
			style.border_width_right = 4
			style.border_width_bottom = 4
			border_shape.add_theme_stylebox_override("panel", style)
			
			add_child(border_shape)
	
	if !clear:
		borders.push_back(border_shape)

func clear_borders():
	for it in borders:
		it.queue_free()
	borders.clear()
	
var highlight_shape
var highlights = []

func draw_highlight(x, y, color, clear):
	if clear and highlight_shape and highlight_shape.is_inside_tree():
		highlight_shape.queue_free()
	
	var pos = Vector2(
		x * CELL_SIZE,
		y * CELL_SIZE
	)
	
	highlight_shape = Panel.new()
	highlight_shape.size = Vector2(CELL_SIZE, CELL_SIZE)
	highlight_shape.position = pos
	highlight_shape.z_index = 20
	
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = color
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	highlight_shape.add_theme_stylebox_override("panel", style)
	
	add_child(highlight_shape)
	
	if !clear:
		highlights.push_back(highlight_shape)

func clear_highlights():
	for it in highlights:
		it.queue_free()
	highlights.clear()

var selection_panel

func draw_selection_box(from : Vector2, to : Vector2, color):
	selection_panel = Panel.new()
	var x = abs(to.x - from.x)
	var y = abs(to.y - from.y)
	selection_panel.size = Vector2(CELL_SIZE * x, CELL_SIZE * y)
	selection_panel.position = Vector2(
		from.x * CELL_SIZE,
		from.y * CELL_SIZE
	)
	selection_panel.z_index = 50
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = color
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	selection_panel.add_theme_stylebox_override("panel", style)
	
	add_child(selection_panel)
	
func clear_selection_box():
	if selection_panel:
		selection_panel.queue_free()
	
var indicators = []
	
func spawn_indicator(pos : Vector2, status : String):
	var indicator = status_indicator.instantiate()
	var xOffset : int
	var yOffset : int
	if (status == "protected"):
		xOffset = 40
	else:
		xOffset = -40
	if (status == "promoted"):
		yOffset = 40
	else:
		yOffset = -40
	indicator.position = Vector2(pos.x * 120 + 60 + xOffset, pos.y * 120 + 60 + yOffset)
	indicator.z_index = 101
	indicator.set_status(status)
	add_child(indicator)
	indicators.push_back(indicator)
	
func clear_indicators():
	for it in indicators:
		it.queue_free()
	indicators.clear()
			
func update_indicators():
	clear_indicators()
	
	for piece in pieces:
		var pos = piece.board_position
		
		if piece.stun_counter > 0:
			spawn_indicator(pos, "stunned")
		if piece_is_protected(piece):
			spawn_indicator(pos, "protected")
		if piece.promoted:
			spawn_indicator(pos, "promoted")

func piece_is_protected(piece):
	var protect_pos: Array
	if shield_king.size() > 0:
		for king in shield_king:
			if king.color == piece.color:
				for pos in king.shield_king_protect_positions():
					protect_pos.append(pos)

	if piece.piece_type == Globals.PIECE_TYPES.DUCK:
		return true
	if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
		return false
		
	# Check if the king actually exists
	if protect_pos.size() == 0:
		return false

	#var shield_king = get_piece(king_pos)
		#
	#if shield_king == null:
		#return false
	
	
	return piece.board_position in protect_pos


	
func num_pieces():
	var count : int = 0
	for piece in pieces:
		if piece.color != Globals.COLORS.TILE:
			count += 1
	return count


func _on_game_init_ai(color) -> void:
	var piecesToSpawn = []
	piecesToSpawn = setup_script.determineAiPieces(color)
	
	var i = 0
	for it in piecesToSpawn.size() / 2:
		create_piece(piecesToSpawn[i], color, piecesToSpawn[i + 1] + Vector2(0, 0 if color == Globals.COLORS.BLACK else -5))
		i += 2
		
	var colorSet
	var total_pieces : int = num_pieces()
	if total_pieces + 1 < Globals.PIECES_PER_SIDE:
		colorSet = Globals.COLORS.WHITE
	elif !is_loadout_board:
		colorSet = Globals.COLORS.BLACK
	SignalBus.emit_signal("set_status", colorSet)

extends Node2D

# Game States
var game_over;
var player_color;
var status; # who is playing
var player2_type; # Where AI or Human is playinh
var white_shield_king_alive = false
var black_shield_king_alive = false

# To drag piece
var is_dragging: bool;
var selected_piece = null;
var previous_position = null;

@onready var board = $Board;
@onready var ui_control = $Control
@onready var win_label = $"Control/Win Label"

# Called when the node enters the scene tree for the first time.
func _ready():
	init_game()
	ui_control.hide()
	win_label.hide()

func _input(event):
	if game_over:
		return
	# Mouse left clicks/drags
	if Input.is_action_just_pressed("left_click"):
		var pos = get_pos_under_mouse()
		selected_piece = board.get_piece(pos)
		# Drag piece only if they are under the mouse or are of current player
		if selected_piece == null or selected_piece.color != status or selected_piece.stun_counter != 0:
			return
		is_dragging = true
		previous_position = selected_piece.position
		selected_piece.z_index = 100
	elif event is InputEventMouseMotion and is_dragging:
		selected_piece.position = get_global_mouse_position()
	elif Input.is_action_just_released("left_click") and is_dragging:
		var is_valid_move = drop_piece()
		if !is_valid_move:
			selected_piece.position = previous_position
		selected_piece.z_index = 0
		selected_piece = null
		is_dragging = false
		
		# Check whether game is over after user's move
		if evaluate_end_game():
			return
		
		
		# If playerA has made valid move, then switch to other player's move
		if is_valid_move:
			player2_move()

func init_game():
	game_over = false
	is_dragging = false
	player_color = Globals.COLORS.WHITE
	status = Globals.COLORS.WHITE
	player2_type = Globals.PLAYER_2_TYPE.HUMAN
	# Check to see if either player has a shield king, and mark it alive if it does.
	for piece in board.pieces:
		if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING && piece.color == Globals.COLORS.WHITE:
			white_shield_king_alive = true
		if piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING && piece.color == Globals.COLORS.BLACK:
			black_shield_king_alive = true
	#player2_type = Globals.PLAYER_2_TYPE.AI

func get_pos_under_mouse():
	var pos = get_global_mouse_position()
	pos.x = int(pos.x / 120)
	pos.y = int(pos.y / 120)
	return pos

func drop_piece():
	var is_shooting = false
	var to_move = get_pos_under_mouse()
	var piece_around
	if valid_move(selected_piece.board_position, to_move):
		# For valid move:
		# - if target has piece, then replace it
		var dest_piece = board.get_piece(to_move)
		# Delete only if the target piece is of different color
		if dest_piece != null and dest_piece.color != selected_piece.color:
			if dest_piece.piece_type == Globals.PIECE_TYPES.TROJAN_HORSE:
				dest_piece.trojan_spawn(dest_piece.color)
			if dest_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP:
				for position in dest_piece.bishop_explode_positions():
					piece_around = board.get_piece(position)
					if piece_around != null:
						board.delete_piece(piece_around)
				if selected_piece.piece_type != Globals.PIECE_TYPES.HORSE_ARCHER:
					board.delete_piece(selected_piece)
			if selected_piece.piece_type == Globals.PIECE_TYPES.EXPLODING_BISHOP:
				for position in dest_piece.bishop_explode_positions():
					piece_around = board.get_piece(position)
					if piece_around != null and piece_around.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
						board.delete_piece(piece_around)
						board.delete_piece(selected_piece)
						end_turn()
						return true
				for pos in dest_piece.bishop_explode_positions():
					piece_around = board.get_piece(pos)
					if piece_around != null:
						board.delete_piece(piece_around)
					board.delete_piece(selected_piece)
			board.delete_piece(dest_piece)
			selected_piece.move_position(selected_piece.board_position)
			if selected_piece.piece_type == Globals.PIECE_TYPES.HORSE_ARCHER:
				is_shooting = true
		if is_shooting == false:
			#print(selected_piece.board_position - to_move)
			selected_piece.move_position(to_move)
			if selected_piece.piece_type == Globals.PIECE_TYPES.STUN_KNIGHT:
				for space in selected_piece.get_stun_positions():
					var piece = board.get_piece(space)
					if piece != null:
						piece.stun_counter = 2
		if selected_piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
			board.register_king(selected_piece.board_position, selected_piece.color)
		# - change currnet status of active color
		#status = Globals.COLORS.BLACK if status == Globals.COLORS.WHITE else Globals.COLORS.WHITE
		end_turn()
		return true
	return false

func valid_move(from_pos, to_pos):
	var board_copy = board.clone()
	var src_piece = board_copy.get_piece(from_pos)
	var shield_king_position
	var shield_king
	
	# If we cannot move to threatend or moveable position
	if(
		to_pos not in src_piece.get_moveable_positions()
		and
		to_pos not in src_piece.get_threatened_positions()
	):
		return false
	
	if status == Globals.COLORS.WHITE && black_shield_king_alive:
		shield_king_position = board.black_king_pos
		shield_king = board_copy.get_piece(shield_king_position)
	elif status == Globals.COLORS.BLACK && white_shield_king_alive:
		shield_king_position = board.white_king_pos
		shield_king = board_copy.get_piece(shield_king_position)
	if src_piece.piece_type != Globals.PIECE_TYPES.EXPLODING_BISHOP && shield_king != null:
		for position in shield_king.shield_king_protect_positions():
			print(position)
			if board_copy.get_piece(position) != null && position == to_pos:
				return false
			
	
	var dst_piece = board_copy.get_piece(to_pos)
	if dst_piece != null:
		board_copy.delete_piece(dst_piece)
	src_piece.move_position(to_pos)
	
	
	
	return true


func get_valid_moves():
	# Get possible moves for current player
	var valid_moves = []
#	var shield_king_position
#	var shield_king
	
	for piece in board.pieces:
		if piece.color == status:
			var candi_pos = piece.get_moveable_positions()
			if piece.piece_type == Globals.PIECE_TYPES.PAWN:
				candi_pos += piece.get_threatened_positions()
			candi_pos = unique(candi_pos)
			for pos in candi_pos:
				if valid_move(piece.board_position, pos):
					valid_moves.append([piece, pos])
#		if status == Globals.COLORS.WHITE && black_shield_king_alive:
#			shield_king_position = board.black_king_pos
#			shield_king = board.get_piece(shield_king_position)
#		elif status == Globals.COLORS.BLACK && white_shield_king_alive:
#			shield_king_position = board.white_king_pos
#			shield_king = board.get_piece(shield_king_position)
#		if piece.piece_type != Globals.PIECE_TYPES.EXPLODING_BISHOP && shield_king != null:
#			for move in valid_moves:
#				for position in shield_king.shield_king_protect_positions():
#					var index = valid_moves.find(move)
#					if valid_moves[index][1] == position:
#						valid_moves.remove_at(index)
	return valid_moves

func unique(arr: Array) -> Array: 
	var dict = {}
	for a in arr:
		dict[a] = 1
	return dict.keys()


func player2_move():
	# Make a move when player2 is AI, else default controller is with user itself
	if player2_type == Globals.PLAYER_2_TYPE.AI:
		var valid_moves = get_valid_moves()
		if len(valid_moves) == 0:
			set_win(Globals.PLAYER.ONE)
			return
		var move = valid_moves.pick_random()
		var piece = move[0]
		var pos = move[1]
		var dest_piece = board.get_piece(pos)
		# Delete only if the target piece is found
		if dest_piece != null:
			board.delete_piece(dest_piece)
		piece.move_position(pos)
		#status = Globals.COLORS.BLACK if status == Globals.COLORS.WHITE else Globals.COLORS.WHITE
		end_turn()
		evaluate_end_game()

func evaluate_end_game():
	# Check whether the current user can make any legal move
	var moves = get_valid_moves()
	if len(moves) == 0:
		game_over = true
		set_win(Globals.PLAYER.TWO if status == player_color else Globals.PLAYER.ONE)
		return true
	return false

func set_win(who: Globals.PLAYER):
	game_over = true
	if who == Globals.PLAYER.ONE:
		win_label.text = "Player One Won"
	else:
		win_label.text = "Player Two Won"
	win_label.show()
	ui_control.show()


func _on_button_pressed():
	get_tree().reload_current_scene()

func end_turn():
	for piece in board.pieces:
		if piece.stun_counter > 0:
			piece.stun_counter -= 1
	status = Globals.COLORS.BLACK if status == Globals.COLORS.WHITE else Globals.COLORS.WHITE

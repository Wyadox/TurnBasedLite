extends Node2D

var explosionScene = preload("res://scenes/Explosion.tscn")

var board_handle

func explode_piece(dest_piece, selected_piece, board):
	explosion_radius(dest_piece, board)
	for position in dest_piece.bishop_explode_positions():
		var piece_around = board.get_piece(position)
		if piece_around != null && not board.piece_is_protected(piece_around):
			board.on_capture(piece_around, selected_piece, board, selected_piece.board_position)
			#board.delete_piece(piece_around)
	return

func spawn_explosion(pos : Vector2):
	var actual_pos = Vector2(pos.x * 120 + 60, pos.y * 120 + 60)
	actual_pos += board_handle.global_position
	
	var explosion = explosionScene.instantiate()
	explosion.position = actual_pos
	add_child(explosion)

func explode_king(dest_piece, selected_piece, board):
	board_handle = board
	
	if dest_piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
		spawn_explosion(dest_piece.board_position)
		board.delete_piece(dest_piece)
		board.delete_piece(selected_piece)
		return true
	for position in dest_piece.bishop_explode_positions():
		var piece_around = board.get_piece(position)
		if piece_around != null and piece_around.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
			spawn_explosion(piece_around.board_position)
			board.delete_piece(piece_around)
			board.delete_piece(selected_piece)
			return true
			# When we have multiple shield kings on board, will need to fix this.
	spawn_explosion(dest_piece.board_position)
	explode_piece(dest_piece, selected_piece, board)
	board.delete_piece(selected_piece)

func explosion_radius(piece, board):
	board_handle = board
	
	for position in piece.explode_spawn_positions():
		var piece_position = board.get_piece(position)
		if piece_position != null:
			spawn_explosion(position)
	return

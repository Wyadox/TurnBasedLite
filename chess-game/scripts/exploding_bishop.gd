extends Node2D

var explosionScene = preload("res://scenes/Explosion.tscn")

var board_handle

var show_explosions : bool = true

func explode_piece(dest_piece, selected_piece, board):
	explosion_radius(dest_piece, board)
	for position in dest_piece.bishop_explode_positions():
		var piece_around = board.get_piece(position)
		if piece_around != null && piece_around.exploded == false && not board.piece_is_protected(piece_around) && not (piece_around.piece_type == Globals.PIECE_TYPES.WATER or piece_around.piece_type == Globals.PIECE_TYPES.MAGMA_HIGH or piece_around.piece_type == Globals.PIECE_TYPES.MAGMA_MED or piece_around.piece_type == Globals.PIECE_TYPES.MAGMA_LOW):
			piece_around.exploded = true
			board.on_capture(piece_around, selected_piece, board, selected_piece.board_position)
			
			#board.delete_piece(piece_around)
	#board.delete_piece(selected_piece, true)
	return

func spawn_explosion(pos : Vector2):
	if !SettingsManager.get_settings().play_particles or not show_explosions:
		return
	
	var actual_pos = Vector2(pos.x * 120 + 60, pos.y * 120 + 60)
	actual_pos += board_handle.global_position
	
	var explosion = explosionScene.instantiate()
	explosion.position = actual_pos
	add_child(explosion)
	
	play_sound()

func spawn_explosion_literal(pos : Vector2):
	if !SettingsManager.get_settings().play_particles or not show_explosions:
		return
	
	var explosion = explosionScene.instantiate()
	explosion.position = pos
	explosion.z_index = 1000
	add_child(explosion)
	
	play_sound()

func explode_king(dest_piece, selected_piece, board):
	board_handle = board
	var king_killed = false
	
	if dest_piece.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
		spawn_explosion(dest_piece.board_position)
		board.delete_piece(dest_piece)
		for king in board.shield_king:
			if king == dest_piece:
				board.shield_king.erase(dest_piece)
		king_killed = true
	for position in dest_piece.bishop_explode_positions():
		var piece_around = board.get_piece(position)
		if piece_around != null and piece_around.piece_type == Globals.PIECE_TYPES.SHIELD_KING:
			spawn_explosion(piece_around.board_position)
			board.delete_piece(piece_around)
			for king in board.shield_king:
				if king == piece_around:
					board.shield_king.erase(piece_around)
			if board_handle.real_board:
				SignalBus.captured_piece.emit(piece_around.color, piece_around.piece_type)
			king_killed = true
			# When we have multiple shield kings on board, will need to fix this.
	spawn_explosion(dest_piece.board_position)
	if king_killed:
		board.delete_piece(selected_piece)
	else:
		explode_piece(dest_piece, selected_piece, board)
		board.delete_piece(selected_piece)
	
	play_sound()

func explosion_radius(piece, board):
	board_handle = board
	
	for position in piece.explode_spawn_positions():
		var piece_position = board.get_piece(position)
		if piece_position != null:
			spawn_explosion(position)
	return

func play_sound():
	if not show_explosions:
		return
	
	var audioPlayer = AudioStreamPlayer2D.new()
	add_child(audioPlayer)
	
	audioPlayer.stream = preload("res://Assets/Sounds/explosion.wav")
	
	audioPlayer.bus = "SFX"
	audioPlayer.play()
	audioPlayer.finished.connect(audioPlayer.queue_free)

extends Node

@warning_ignore("unused_signal")
signal spawn_piece(piece_type)

@warning_ignore("unused_signal")
signal refund_piece(piece_type)

@warning_ignore("unused_signal")
signal set_status(color)

@warning_ignore("unused_signal")
signal spawn_ai()

@warning_ignore("unused_signal")
signal setup_complete

@warning_ignore("unused_signal")
signal init_ai(color)

@warning_ignore("unused_signal")
signal test(data)

@warning_ignore("unused_signal")
signal selected_square(pos)

@warning_ignore("unused_signal")
signal piece_moved(old_pos, board_position)

@warning_ignore("unused_signal")
signal mitosis_spawned(position)

@warning_ignore("unused_signal")
signal trojan_spawned(position)

@warning_ignore("unused_signal")
signal loadout_button(loadout)

@warning_ignore("unused_signal")
signal setup_piece_by_type(piece_type)

@warning_ignore("unused_signal")
signal show_notification(phrase)

# Used for Captured Pieces Display
@warning_ignore("unused_signal")
signal captured_piece(color, piece_type)

# Used to set the map in the options/coin menu
@warning_ignore("unused_signal")
signal change_map(current_map)

# Used for Previous Move display
@warning_ignore("unused_signal")
signal previous_move(piece_type, color, old_pos, new_pos)

# Used for Move History display
@warning_ignore("unused_signal")
signal archive_move(piece_type, color, old_pos, new_pos)

# Used for when Move Clock runs out 
@warning_ignore("unused_signal")
signal move_clock_expired()

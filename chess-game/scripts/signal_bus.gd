extends Node

signal human_op
signal ai_op
signal spawn_piece(piece_type)
signal refund_piece(piece_type)
signal set_status(color)
signal spawn_ai()
signal setup_complete
signal init_ai(color)
signal test(data)
signal selected_square(pos)
signal piece_moved(old_pos, board_position)
signal mitosis_spawned(position)
signal trojan_spawned(position)

signal loadout_button(loadout)

signal setup_piece_by_type(piece_type)

signal show_notification(phrase)

# Used for Captured Pieces Display
signal captured_piece(color, piece_type)

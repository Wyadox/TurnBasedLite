extends Node2D

@onready var board: Node2D = $Board


var piece_eval = {"PAWN" : 1, "MITOSIS_PAWN" : 1.25, "WORM" : 1.5, "CHECKER" : 1.5, "INFECTOR" : 2, "DUPLICATOR": 2, 
				"HORSE_ARCHER" : 3, "STUN_KNIGHT": 3.75, "TROJAN_HORSE": 3.5, "MAGMA_KNIGHT": 3.75, "WAR_HORSE": 4, 
				"EXPLODING_BISHOP" : 4, "ACROBISHOP": 3.5, "ARCHBISHOP" : 4, "JOUSTING_BISHOP": 3.5,
				"SUMO": 5.5, "WIZARD": 5.5,
				"SHIELD_KING": 5, "JUGGERNAUT": 3,
				"DUCK" : 1, "GUARDIAN_ANGEL": 3}

extends Node2D

func set_status(type : String):
	match  type:
		"protected":
			$Sprite2D.texture = preload("res://ShieldIndicator.png")
		"stunned":
			$Sprite2D.texture = preload("res://StunIndicator.png")
		"none":
				queue_free()

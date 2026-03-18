extends Node2D

func set_status(type : String):
	match  type:
		"protected":
			$Sprite2D.texture = preload("res://Assets/ShieldIndicator.png")
		"stunned":
			$Sprite2D.texture = preload("res://Assets/StunIndicator.png")
		"promoted":
			$Sprite2D.texture = preload("res://Assets/PromotedIndicator.png")
		"none":
				queue_free()

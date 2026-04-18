class_name FriendlyTarget
extends Control

var color := Color.YELLOW
var radius := 8

var distance := 25.0
var width := 10

func _draw() -> void:
	var c = size / 2
	draw_line(c + Vector2(-radius, 0), c + Vector2(-radius + distance, 0), color, width)
	draw_line(c + Vector2(radius, 0), c + Vector2(radius - distance, 0), color, width)
	draw_line(c + Vector2(0, -radius), c + Vector2(0, -radius + distance), color, width)
	draw_line(c + Vector2(0, radius), c + Vector2(0, radius - distance), color, width)

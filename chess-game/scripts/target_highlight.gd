class_name Target
extends Control

var color := Color.YELLOW
var radius := 8

var distance := 25.0
var width := 10

func _draw() -> void:
	#draw_circle(size / 2, radius, color, false, 4, true)
	var c = size / 2
	draw_line(c + Vector2(-radius, -radius), c + Vector2(-radius + distance, -radius + distance), color, width)
	draw_line(c + Vector2(radius, radius), c + Vector2(radius - distance, radius - distance), color, width)
	draw_line(c + Vector2(radius, -radius), c + Vector2(radius - distance, -radius + distance), color, width)
	draw_line(c + Vector2(-radius, radius), c + Vector2(-radius + distance, radius - distance), color, width)

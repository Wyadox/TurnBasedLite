class_name Circle
extends Control

var color := Color.YELLOW
var radius := 8

func _draw() -> void:
	draw_circle(size / 2, radius, color)

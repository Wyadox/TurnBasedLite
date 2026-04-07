extends Control

var speed : float = 1.0
var target : float = 5.0

func _process(delta: float) -> void:
	$ProgressBar.value = move_toward($ProgressBar.value as float, target, speed * delta)
	if abs($ProgressBar.value - target) < 0.025:
		$ProgressBar.value = target

func set_target(num : float):
	target = num * 10

func set_value(num : float):
	$ProgressBar.value = num

func fill_mode_TTB():
	$ProgressBar.fill_mode = ProgressBar.FILL_TOP_TO_BOTTOM

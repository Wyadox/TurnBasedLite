extends Control

@onready var label: Label = $Panel/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_text(phrase : String):
	label.text = phrase
	appear()

func appear():
	show()
	await get_tree().create_timer(1.5).timeout
	hide()

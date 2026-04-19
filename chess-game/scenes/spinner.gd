class_name Spinner
extends Control

signal result(color)

@onready var sprite: Sprite2D = $Sprite2D
@onready var spinner_rect: TextureRect = $Spinner_Whole/Spinner_Rect
@onready var white_rect: TextureRect = $Spinner_Whole/White_Rect
@onready var black_rect: TextureRect = $Spinner_Whole/Black_Rect
@onready var white_button: DynamicButton = $HBoxContainer/White_Button
@onready var black_button: DynamicButton = $HBoxContainer/Black_Button
@onready var spinner_whole: Control = $Spinner_Whole
@onready var duration: Timer = $Duration
@onready var label: Label = $Label

const TEXTURE = preload("res://Assets/Spinner/Spinner.png")
const WHEEL_SOUND = preload("res://Assets/Sounds/freesound_community-wheel-spin-click-slow-down-101152.mp3")

const SPRITE_SIZE : int = 32
const SPIN_MINIMUM : int = 3
const SPIN_MAXIMUM : int = 6
const SPIN_INCREMENT : int = 150
const MAX_SPIN_SPEED : int = 500

var audioPlayer = AudioStreamPlayer2D
var choice : Globals.COLORS
var white_piece : Globals.PIECE_TYPES
var black_piece : Globals.PIECE_TYPES
var spinning : bool = false
var spin_duration : float = 0.0
var current_spin_speed : float = 0.0
var direction : int = 1

func _ready() -> void:
	randomize()
	
	audioPlayer = AudioStreamPlayer2D.new()
	add_child(audioPlayer)
	
	white_piece = randi_range(0, Globals.PIECE_TYPES.size() - 8) as Globals.PIECE_TYPES
	black_piece = white_piece
	while black_piece == white_piece:
		black_piece = randi_range(0, Globals.PIECE_TYPES.size() - 8) as Globals.PIECE_TYPES
	
	white_button.set_texture(grab_region(white_piece, Globals.COLORS.WHITE))
	black_button.set_texture(grab_region(black_piece, Globals.COLORS.BLACK))
	
	white_rect.texture = grab_region(white_piece, Globals.COLORS.WHITE)
	black_rect.texture = grab_region(black_piece, Globals.COLORS.BLACK)
	
	white_button.button_triggered.connect(on_white_button)
	black_button.button_triggered.connect(on_black_button)
	
	duration.timeout.connect(on_time_reached)
	
	label.text = "CHOOSE"

func _process(delta: float) -> void:
	if !spinning:
		return
	
	spinner_whole.rotation += deg_to_rad(current_spin_speed) * delta
	current_spin_speed += delta * SPIN_INCREMENT * direction
	
	if current_spin_speed > MAX_SPIN_SPEED:
		current_spin_speed = MAX_SPIN_SPEED
	
	if current_spin_speed <= 0:
		current_spin_speed = 0
		spinning = false
		process_spin()

func on_white_button():
	choice = Globals.COLORS.WHITE
	white_button.select()
	disable_buttons()
	spin()

func on_black_button():
	choice = Globals.COLORS.BLACK
	black_button.select()
	disable_buttons()
	spin()

func disable_buttons():
	white_button.disable()
	black_button.disable()

func grab_region(piece_type, color):
	var region_pos = Globals.SPRITE_MAPPING[color][piece_type]
	var region = Rect2(
		region_pos.y * SPRITE_SIZE,
		region_pos.x * SPRITE_SIZE,
		SPRITE_SIZE,
		SPRITE_SIZE
	)
	
	var atlas := AtlasTexture.new()
	atlas.atlas = sprite.texture
	atlas.region = region
	
	return atlas

func spin():
	spin_duration = randf_range(SPIN_MINIMUM, SPIN_MAXIMUM)
	duration.wait_time = spin_duration
	duration.start()
	label.text = "SPINNING..."
	spinning = true
	
	audioPlayer.stream = WHEEL_SOUND
	audioPlayer.volume_db = linear_to_db(0.5)
	audioPlayer.play()

func on_time_reached():
	direction = -1
	
	audioPlayer.stream = WHEEL_SOUND
	audioPlayer.volume_db = linear_to_db(0.5)
	audioPlayer.play()

func process_spin():
	var normal_rotation = fposmod(spinner_whole.rotation, TAU)
	print("final rotation: ", rad_to_deg(normal_rotation))
	var winning_piece : Globals.PIECE_TYPES
	
	if normal_rotation >= PI/2 and normal_rotation <= 3*PI/2:
		print(Globals.PIECE_TYPES.find_key(black_piece))
		winning_piece = black_piece
	else:
		print(Globals.PIECE_TYPES.find_key(white_piece))
		winning_piece = white_piece
	
	var winning_text = "YOU WON : PLAYING AS WHITE"
	if choice == Globals.COLORS.WHITE and winning_piece == white_piece:
		result.emit(Globals.COLORS.WHITE)
		label.text = winning_text
	elif choice == Globals.COLORS.BLACK and winning_piece == black_piece:
		result.emit(Globals.COLORS.WHITE)
		label.text = winning_text
	else:
		result.emit(Globals.COLORS.BLACK)
		label.text = "YOU LOST : PLAYING AS BLACK"

class_name Player
extends CharacterBody2D

const JUMP_VELOCITY = -500.0

@export var speed = 500
@export_range(-1,1,2) var x_direction = 1
@export var spriteTexture: Texture2D
@export var camera_limit_left: int = -100
@export var camera_limit_right: int = 100
@export var camera_limit_top: int = -99999
@export var camera_limit_bottom : int = 650

var is_in_knockback: bool = false
@onready var sprite: Sprite2D = $CollisionShape2D/Sprite2D
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	#pass
	camera.limit_left = camera_limit_left
	camera.limit_right = camera_limit_right
	camera.limit_top = camera_limit_top
	camera.limit_bottom = camera_limit_bottom
	sprite.texture = spriteTexture
	

func get_input():
	var input_direction = Input.get_vector("left", "right", "ui_up", "ui_down")
	velocity.x = input_direction.x * speed * x_direction

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump
	if not is_in_knockback:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		get_input()
	move_and_slide()

func take_damage_and_bounce(hazard_global_pos: Vector2) -> void:
	if velocity.x != 0:
		# Reverse previous direction (-1 if moving right, 1 if moving left)
		velocity.x = -sign(velocity.x) * speed * 0.3
	else:
		# If stationary, push away from the hazard center
		var push_direction = sign(global_position.x - hazard_global_pos.x)
		if push_direction == 0: 
			push_direction = 1 # Fallback if exactly centered
		velocity.x = push_direction * speed * 0.3

	# 2. Apply Upward Lift
	velocity.y = JUMP_VELOCITY
	
	is_in_knockback = true
	
	await get_tree().create_timer(1).timeout
	
	# Optional: Trigger hurt animation or invincibility frames here

	#get_tree().change_scene_to_file("res://ui/game_over.tscn")

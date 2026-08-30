class_name Player
extends CharacterBody2D

@export var speed = 500
@export var camera_limit_left: int = -100
@export var camera_limit_right: int = 100
@export var camera_limit_top: int = -99999
@export var camera_limit_bottom : int = 650

@export_enum("left", "right") var player_face: String = "right"
var is_grabbing: bool = false

var is_in_knockback: bool = false
@onready var sprite: AnimatedSprite2D = $CollisionShape2D/Sprite2D
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	#pass
	camera.limit_left = camera_limit_left
	camera.limit_right = camera_limit_right
	camera.limit_top = camera_limit_top
	camera.limit_bottom = camera_limit_bottom
	

func get_input():
	if GameState.is_inventory_open:
		return
	if is_grabbing:
		return
	var input_direction = Input.get_vector("left", "right", "ui_up", "ui_down")
	velocity.x = input_direction.x * speed


func _process(delta: float) -> void:
	if GameState.is_inventory_open:
		velocity.x = 0
		sprite.play("idle_" + player_face)
		return
	if is_grabbing:
		velocity.x = 0
		return
	if Input.is_action_pressed("left"):
		sprite.play("run_left")
		player_face = "left"
	elif Input.is_action_pressed("right"):
		sprite.play("run_right")
		player_face = "right"
	else :
		sprite.play("idle_" + player_face)
		
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		SceneManager.toggle_inventory()

func play_grab_animation() -> void:
	is_grabbing = true
	sprite.play("grab_" + player_face)
	await sprite.animation_finished
	is_grabbing = false


func _physics_process(delta):
	# Apply gravity
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	## Handle jump
	#if not is_in_knockback:
		#if Input.is_action_just_pressed("jump") and is_on_floor():
			#velocity.y = JUMP_VELOCITY

	get_input()
	move_and_slide()

#func take_damage_and_bounce(hazard_global_pos: Vector2) -> void:
	#if velocity.x != 0:
		## Reverse previous direction (-1 if moving right, 1 if moving left)
		#velocity.x = -sign(velocity.x) * speed * 0.3
	#else:
		## If stationary, push away from the hazard center
		#var push_direction = sign(global_position.x - hazard_global_pos.x)
		#if push_direction == 0: 
			#push_direction = 1 # Fallback if exactly centered
		#velocity.x = push_direction * speed * 0.3
#
	## 2. Apply Upward Lift
	#velocity.y = JUMP_VELOCITY
	#
	#is_in_knockback = true
	#
	#await get_tree().create_timer(1).timeout
	
	# Optional: Trigger hurt animation or invincibility frames here

	#get_tree().change_scene_to_file("res://ui/game_over.tscn")

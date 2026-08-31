extends CharacterBody2D
class_name NPC

@export var move_speed: float = 100.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_chased: bool = false # Flag jika sedang dikejar anjing
var is_ride: bool = false
var face_direction = "left"
var _paket: Array[String] = []

@export var npc_id: String = "mc_npc"

func _ready() -> void:
	# Daftarkan node ke GameState
	GameState.register_npc_node(npc_id, self)

	var my_state = GameState.get_npc_state(npc_id)
	var target_level = my_state.get("current_level", "")

	# Jika NPC seharusnya tidak berada di scene level ini, hapus dari node scene
	if target_level != "" and target_level != get_tree().current_scene.scene_file_path:
		queue_free() # NPC disembunyikan/dihapus dari level ini

func _physics_process(delta: float) -> void:
	if is_chased:
		# Logika tambahan jika dikejar anjing (misal lari lebih cepat)
		move_speed = 200.0
	
	if is_moving:
		var direction = global_position.direction_to(current_target_position)
		if direction.x > 0:
			face_direction = "right"
		elif direction.x < 0:
			face_direction = "left"
		velocity = direction * move_speed
		
		# Putar animasi lari/jalan sesuai arah
		if direction.x != 0:
			if is_ride:
				sprite.play("ride_right")
			else :
				sprite.play("run_right" if direction.x > 0 else "run_left")
			
		# Hentikan jika sudah dekat dengan target
		if global_position.distance_to(current_target_position) < 5.0:
			velocity = Vector2.ZERO
			is_moving = false
			sprite.play("idle_"+face_direction)
		
		move_and_slide()

# Memindahkan NPC ke posisi target
func move_to_location(target_pos: Vector2) -> void:
	current_target_position = target_pos
	is_moving = true

# Fungsi helper pemutar animasi aksi spesifik
func play_action_animation(anim_name: String, from_end: bool = false) -> void:
	is_moving = false
	velocity = Vector2.ZERO
	sprite.play(anim_name, 1, from_end)
	await sprite.animation_finished
	sprite.play("idle_"+face_direction)
	
func add_paket(nama: String):
	_paket.append(nama)
	var paket_node: Sprite2D = get_node("Sepeda/"+nama)
	$Sepeda.visible = true
	paket_node.visible = true

func remove_paket():
	var nama = _paket.pop_back()
	var paket_node: Sprite2D = get_node("Sepeda/"+nama)
	paket_node.visible = false

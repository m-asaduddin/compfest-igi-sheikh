extends CharacterBody2D
class_name NPC

@export var run_speed: float = 250.0

var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var face_direction: String = "right"

@onready var sprite = $CollisionShape2D/Sprite2D

# Jadwal lokasi NPC sesuai tahapan cerita di StoryOrchestrator
@export var scene_schedule: Dictionary = {
	"mc_house": "res://scenes/levels/mc_home.tscn",
	"mc_gudang": "res://scenes/levels/main_street.tscn",
	"base_proceed": "res://scenes/levels/warehouse.tscn"
}

func _ready() -> void:
	add_to_group("NPC")
	
	# 1. Cek apakah NPC harus ada di scene aktif saat ini
	if not _evaluate_presence():
		return # Jika bukan di scene-nya, NPC dihapus (queue_free)
		
	# 2. Jalankan aksi cerita yang sedang berlangsung
	_execute_story_action(StoryOrchestrator.get_current_action())

func _evaluate_presence() -> bool:
	var current_action = StoryOrchestrator.get_current_action()
	var current_scene_file = get_tree().current_scene.scene_file_path
	
	if scene_schedule.has(current_action):
		var target_scene_for_step = scene_schedule[current_action]
		# Jika scene aktif beda dengan scene tugas NPC, hapus instance NPC ini
		if current_scene_file != target_scene_for_step:
			queue_free()
			return false
			
	return true

func _physics_process(_delta: float) -> void:
	if is_moving:
		var dir_x = sign(target_position.x - global_position.x)
		if dir_x > 0:
			face_direction = "right"
		elif dir_x < 0:
			face_direction = "left"
			
		velocity.x = dir_x * run_speed
		velocity.y = 0
		
		if sprite and sprite.has_method("play"):
			sprite.play("run_" + face_direction)
		
		# Deteksi jika NPC sudah mencapai target portalnya
		if abs(global_position.x - target_position.x) < 10.0:
			velocity = Vector2.ZERO
			is_moving = false
			_on_target_reached()
		else:
			move_and_slide()

func _process(_delta: float) -> void:
	if not is_moving and sprite and sprite.has_method("play"):
		sprite.play("idle_" + face_direction)

func _execute_story_action(action_name: String) -> void:
	match action_name:
		"mc_house":
			var portal_exit = get_parent().find_child("Portal", true, false)
			if portal_exit:
				run_to(portal_exit.global_position)

		"mc_gudang":
			var portal_gudang = get_parent().find_child("portal_warehouse", true, false)
			if portal_gudang:
				run_to(portal_gudang.global_position)

func run_to(destination: Vector2) -> void:
	target_position = Vector2(destination.x, global_position.y)
	is_moving = true

# Dipanggil MURNI HANYA SAAT NPC sampai di portal tujuan
func _on_target_reached() -> void:
	var current_action = StoryOrchestrator.get_current_action()
	
	if current_action == "mc_house":
		hide()
		set_physics_process(false)
		
		# HANYA di sini state cerita dimajukan ke step berikutnya!
		StoryOrchestrator.resolve_action_completion("mc_house")
		queue_free()

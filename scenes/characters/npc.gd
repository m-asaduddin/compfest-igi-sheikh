extends CharacterBody2D
class_name NPC

@export var run_speed: float = 200.0

const DROPPED_PAKET_SCENE = preload("res://scenes/objects/dropped_paket.tscn")

var start_pos: Vector2
var target_pos: Vector2
var is_moving: bool = false
var face_direction: String = "right"

# Dog chase state
var is_fleeing_from_dog: bool = false
var _paket_dropped: bool = false

@onready var sprite = $CollisionShape2D/Sprite2D

# Jadwal lokasi NPC sesuai tahapan cerita di StoryOrchestrator
@export var scene_schedule: Dictionary = {
	"mc_house": "res://scenes/levels/mc_home.tscn",
	"mc_gudang": "res://scenes/levels/main_street.tscn",
	"base_proceed": "res://scenes/levels/warehouse.tscn",
	"ambil_paket": "res://scenes/levels/warehouse.tscn",
	"antar_paket_1": "res://scenes/levels/main_street.tscn",
	"paket_proceeding": "res://scenes/levels/main_street.tscn",
	"antar_paket_x": "res://scenes/levels/main_street.tscn",
	"antar_paket_start": "res://scenes/levels/main_street.tscn",
	"antar_paket_2": "res://scenes/levels/gang_melati.tscn",
	"antar_paket_proceeding": "res://scenes/levels/main_street.tscn",
}

# Mapping from action name to movement animation prefix
@export var action_animations: Dictionary = {
	"mc_house": "run",
	"mc_gudang": "run",
	"base_proceed": "run",
	"ambil_paket": "run",
	"antar_paket_1": "ride",
	"paket_proceeding": "ride",
	"antar_paket_x": "ride",
	"antar_paket_start": "ride",
	"antar_paket_2": "ride",
	"antar_paket_proceeding": "ride",
}

# Mapping from action to reaching/finishing animation and duration (in seconds)
@export var reach_actions: Dictionary = {
	"base_proceed": {"animation": "grab", "duration": 1.5, "reversed": false},
	"paket_proceeding": {"animation": "grab", "duration": 1.5, "reversed": true},
}

var _initialized_action: String = ""
var _is_playing_reach_anim: bool = false
var _reach_timer: float = 0.0
var _reach_duration: float = 0.0
var _reach_anim_prefix: String = ""
var _reach_anim_reverse: bool = false

func _ready() -> void:
	add_to_group("NPC")
	if StoryOrchestrator.player_affected_world_state.get("npc_fled", false):
		visible = false
		set_physics_process(false)
		return
	elif StoryOrchestrator.player_affected_world_state.get("chase_active", false):
		is_fleeing_from_dog = true
		visible = true
		set_physics_process(true)
		global_position.x = StoryOrchestrator.player_affected_world_state.get("npc_chase_x", global_position.x)
	else:
		_update_presence_and_movement()

func _process(_delta: float) -> void:
	# If fleeing from dog, skip normal story presence/movement update
	if not is_fleeing_from_dog:
		_update_presence_and_movement()
	
	if sprite and sprite.has_method("play"):
		var action = StoryOrchestrator.get_current_action()
		var anim_prefix = action_animations.get(action, "run")
		
		# Handle Sepeda (bike) visibility — hidden when fleeing (paket already dropped)
		var sepeda = find_child("Sepeda", true, false)
		if sepeda:
			if is_fleeing_from_dog:
				sepeda.visible = false
			else:
				sepeda.visible = (anim_prefix == "ride")
		
		if is_fleeing_from_dog:
			# Always play run_left when fleeing
			if sprite.sprite_frames.has_animation("run_left"):
				sprite.play("run_left")
			else:
				sprite.play("run_right")
				sprite.flip_h = true
			sprite.flip_h = false
		elif _is_playing_reach_anim:
			var anim_name = _reach_anim_prefix + "_" + face_direction
			if sprite.sprite_frames.has_animation(anim_name):
				sprite.play(anim_name)
			else:
				sprite.play("idle_" + face_direction)
			sprite.flip_h = false
		elif is_moving:
			var anim_name = anim_prefix + "_" + face_direction
			if sprite.sprite_frames.has_animation(anim_name):
				if _reach_anim_reverse:
					sprite.play_backwards(anim_name)
				else:
					sprite.play(anim_name)
				sprite.flip_h = false
			elif sprite.sprite_frames.has_animation(anim_prefix + "_right"):
				# Fallback if only right animation exists (like ride_right) and flip horizontally
				if _reach_anim_reverse:
					sprite.play_backwards(anim_prefix + "_right")
				else:
					sprite.play(anim_prefix + "_right")
				sprite.flip_h = (face_direction == "left")
			else:
				# General fallback to run
				sprite.play("run_" + face_direction)
				sprite.flip_h = false
		else:
			# Idle animation
			sprite.play("idle_" + face_direction)
			sprite.flip_h = false

func _update_presence_and_movement() -> void:
	if StoryOrchestrator.player_affected_world_state.get("npc_fled", false):
		visible = false
		set_physics_process(false)
		return

	var current_action = StoryOrchestrator.get_current_action()
	var current_scene_file = get_tree().current_scene.scene_file_path
	
	var should_be_active = false
	if scene_schedule.has(current_action):
		var target_scene_for_step = scene_schedule[current_action]
		if current_scene_file == target_scene_for_step:
			should_be_active = true
			
	if should_be_active:
		if _initialized_action != current_action or not visible or not is_physics_processing():
			visible = true
			set_physics_process(true)
			_initialized_action = current_action
			_is_playing_reach_anim = false
			_setup_background_position()
	else:
		if visible or is_physics_processing() or _initialized_action != "":
			visible = false
			is_moving = false
			_is_playing_reach_anim = false
			set_physics_process(false)
			_initialized_action = ""

func _setup_background_position() -> void:
	var action = StoryOrchestrator.get_current_action()
	var nodes = _get_action_nodes(action)
	
	var start_node = nodes["start"]
	var target_node = nodes["target"]
	
	if start_node:
		start_pos = start_node.global_position
	else:
		start_pos = global_position # fallback to initial scene position
		
	if target_node:
		target_pos = target_node.global_position
	else:
		target_pos = global_position # fallback/no movement
		
	# Hitung posisi fisik NPC berdasarkan progress simulasi latar belakang!
	var current_progress = StoryOrchestrator.npc_progress
	global_position = start_pos.lerp(target_pos, current_progress)
	
	# Jika di latar belakang belum sampai, lanjutkan berjalan secara fisik
	if current_progress < 1.0 and start_pos != target_pos:
		run_to(target_pos)
	else:
		is_moving = false

func _get_action_nodes(action_name: String) -> Dictionary:
	var start_node = null
	var target_node = null
	
	match action_name:
		"mc_house":
			start_node = get_parent().find_child("NPCStartSpot", true, false)
			target_node = get_parent().find_child("Portal", true, false)
		"mc_gudang":
			start_node = get_parent().find_child("mc_home", true, false)
			target_node = get_parent().find_child("portal_warehouse", true, false)
		"base_proceed":
			start_node = get_parent().find_child("antar_paket_1", true, false)
			target_node = get_parent().find_child("ambil_paket", true, false)
		"ambil_paket":
			start_node = get_parent().find_child("ambil_paket", true, false)
			target_node = get_parent().find_child("antar_paket_1", true, false)
		"antar_paket_1":
			start_node = get_parent().find_child("SpawnFromWarehouse", true, false)
			target_node = get_parent().find_child("home_1", true, false)
		"paket_proceeding":
			start_node = get_parent().find_child("home_1", true, false)
			target_node = get_parent().find_child("paket_proceeding", true, false)
		"antar_paket_x":
			start_node = get_parent().find_child("paket_proceeding", true, false)
			target_node = get_parent().find_child("antar_paket_x", true, false)
		"antar_paket_start":
			start_node = get_parent().find_child("paket_proceeding", true, false)
			target_node = get_parent().find_child("portal_gang_2_start", true, false)
		"antar_paket_2":
			start_node = get_parent().find_child("SpawnLeft", true, false)
			target_node = get_parent().find_child("antar_paket_start", true, false)
		"antar_paket_proceeding":
			start_node = get_parent().find_child("SpawnFromGang2End", true, false)
			target_node = get_parent().find_child("antar_paket_x", true, false)
	return {"start": start_node, "target": target_node}

func _physics_process(delta: float) -> void:
	# Dog chase: NPC runs left indefinitely until off screen
	if is_fleeing_from_dog:
		velocity.x = -run_speed
		velocity.y = 0.0
		face_direction = "left"
		move_and_slide()
		StoryOrchestrator.player_affected_world_state["npc_chase_x"] = global_position.x
		if global_position.x <= -100.0:
			visible = false
			set_physics_process(false)
		return

	if _is_playing_reach_anim:
		_reach_timer += delta
		if _reach_timer >= _reach_duration:
			_is_playing_reach_anim = false
			StoryOrchestrator.npc_progress = 1.0
			StoryOrchestrator.resolve_action_completion(StoryOrchestrator.get_current_action())
		return

	if is_moving:
		var dir_x = sign(target_pos.x - global_position.x)
		if dir_x == 0:
			dir_x = 1
			
		velocity.x = dir_x * run_speed
		velocity.y = 0.0
		
		if dir_x > 0:
			face_direction = "right"
		else:
			face_direction = "left"
			
		move_and_slide()
		
		# Update progress ke StoryOrchestrator
		var total_dist = abs(target_pos.x - start_pos.x)
		if total_dist > 0.0:
			var current_dist = abs(global_position.x - start_pos.x)
			StoryOrchestrator.npc_progress = clamp(current_dist / total_dist, 0.0, 1.0)
			
		# Cek jika sampai
		if abs(global_position.x - target_pos.x) < 15.0:
			is_moving = false
			var action = StoryOrchestrator.get_current_action()
			if reach_actions.has(action):
				_is_playing_reach_anim = true
				_reach_timer = 0.0
				_reach_duration = reach_actions[action]["duration"]
				_reach_anim_prefix = reach_actions[action]["animation"]
				_reach_anim_reverse = reach_actions[action]["reversed"]
			else:
				StoryOrchestrator.npc_progress = 1.0
				StoryOrchestrator.resolve_action_completion(action)

func run_to(destination: Vector2) -> void:
	target_pos = Vector2(destination.x, global_position.y)
	is_moving = true

# Called by the dog when it detects and chases the NPC
func flee_from_dog() -> void:
	if is_fleeing_from_dog:
		return
	is_fleeing_from_dog = true
	is_moving = false
	_is_playing_reach_anim = false
	
	# Mark chase active and save initial flee position in StoryOrchestrator
	StoryOrchestrator.player_affected_world_state["chase_active"] = true
	StoryOrchestrator.player_affected_world_state["chase_timer"] = 0.0
	StoryOrchestrator.player_affected_world_state["npc_start_flee_x"] = global_position.x
	StoryOrchestrator.player_affected_world_state["npc_chase_x"] = global_position.x
	StoryOrchestrator.npc_is_travelling = false
	
	# Drop the paket at NPC current position before fleeing
	if not StoryOrchestrator.player_affected_world_state.get("paket_dropped", false):
		StoryOrchestrator.player_affected_world_state["paket_dropped"] = true
		StoryOrchestrator.player_affected_world_state["paket_dropped_x"] = global_position.x
		StoryOrchestrator.player_affected_world_state["paket_dropped_y"] = global_position.y
		_paket_dropped = true
		
		var paket_instance = DROPPED_PAKET_SCENE.instantiate()
		get_parent().add_child(paket_instance)
		paket_instance.global_position = global_position


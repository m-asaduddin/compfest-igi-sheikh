extends InteractiveObject

@export var chase_speed: float = 280.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var _is_chasing: bool = false
var _target_npc: NPC = null
var _chase_direction: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if StoryOrchestrator.player_affected_world_state.get("npc_fled", false):
		visible = false
		set_process(false)
		return
	elif StoryOrchestrator.player_affected_world_state.get("chase_active", false):
		global_position.x = StoryOrchestrator.player_affected_world_state.get("dog_chase_x", global_position.x)
		var timer: float = StoryOrchestrator.player_affected_world_state.get("chase_timer", 0.0)
		if timer >= 2.0:
			_is_chasing = true
			_chase_direction = -1.0
			anim.flip_h = true
			anim.play("run")
		else:
			if StoryOrchestrator.player_affected_world_state.get("dog_unleashed", false):
				anim.play("idle_unleashed")
			else:
				anim.play("idle")
	elif StoryOrchestrator.player_affected_world_state.get("dog_unleashed", false):
		anim.play("idle_unleashed")
	else:
		anim.play("idle")

func _process(delta: float) -> void:
	if not _is_chasing:
		return
	# Move left or toward target NPC position
	var dir = -1.0
	if _target_npc and is_instance_valid(_target_npc):
		dir = sign(_target_npc.global_position.x - global_position.x)
		if dir == 0:
			dir = _chase_direction
	else:
		dir = _chase_direction
		
	global_position.x += dir * chase_speed * delta
	StoryOrchestrator.player_affected_world_state["dog_chase_x"] = global_position.x
	
	if global_position.x <= -100.0:
		visible = false
		_is_chasing = false
		set_process(false)

func apply_result(result: Dictionary) -> void:
	super.apply_result(result)
	if result.get("success", false):
		StoryOrchestrator.player_affected_world_state["dog_unleashed"] = true
		SceneManager.show_dialog("Tali anjing berhasil dipotong!")
		anim.play("idle_unleashed")

# Called by the dog's DetectionArea when an NPC body enters
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is NPC and not _is_chasing:
		# Only chase and flee if the dog is unleashed
		if StoryOrchestrator.player_affected_world_state.get("dog_unleashed", false):
			var npc := body as NPC
			StoryOrchestrator.player_affected_world_state["dog_start_chase_x"] = global_position.x
			StoryOrchestrator.player_affected_world_state["dog_chase_x"] = global_position.x
			npc.flee_from_dog()
			await get_tree().create_timer(2.0).timeout
			_start_chasing(npc)

func _start_chasing(npc: NPC) -> void:
	_is_chasing = true
	_target_npc = npc
	anim.flip_h = true
	_chase_direction = -1.0
	anim.play("run")

	# Tell the NPC to flee

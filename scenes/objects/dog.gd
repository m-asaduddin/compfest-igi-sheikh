extends InteractiveObject

@export var chase_speed: float = 280.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var _is_chasing: bool = false
var _target_npc: NPC = null
var _chase_direction: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if StoryOrchestrator.player_affected_world_state.get("dog_unleashed", false):
		anim.play("idle_unleashed")
	else:
		anim.play("idle")

func _process(delta: float) -> void:
	if not _is_chasing or _target_npc == null:
		return
	# Chase NPC: move toward the NPC's x position directly (Area2D has no move_and_slide)
	var dir = sign(_target_npc.global_position.x - global_position.x)
	if dir == 0:
		dir = _chase_direction
	global_position.x += dir * chase_speed * delta

func apply_result(result: Dictionary) -> void:
	super.apply_result(result)
	if result.get("success", false):
		StoryOrchestrator.player_affected_world_state["dog_unleashed"] = true
		SceneManager.show_dialog("Tali anjing berhasil dipotong!")
		anim.play("idle_unleashed")

# Called by the dog's DetectionArea when an NPC body enters
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is NPC and not _is_chasing:
		var npc := body as NPC
		npc.flee_from_dog()
		await get_tree().create_timer(2.0).timeout
		# Only chase if the dog is unleashed
		if StoryOrchestrator.player_affected_world_state.get("dog_unleashed", false):
			_start_chasing(npc)

func _start_chasing(npc: NPC) -> void:
	_is_chasing = true
	_target_npc = npc
	anim.flip_h = true
	_chase_direction = sign(npc.global_position.x - global_position.x)
	anim.play("run")
	# Tell the NPC to flee

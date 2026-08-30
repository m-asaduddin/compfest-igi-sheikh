extends InteractiveObject


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	anim.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_result(result: Dictionary) -> void:
	super.apply_result(result)
	if result.get("success", false):
		StoryOrchestrator.player_affected_world_state["dog_unleashed"] = true
		SceneManager.show_dialog("Tali anjing berhasil dipotong!")
		anim.play("idle_unleashed")

extends InteractiveObject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	sprite.visible = false
	
func apply_result(result: Dictionary) -> void:
	super.apply_result(result)
	if result.get("success", false):
		#SceneManager.toggle_inventory()
		StoryOrchestrator.player_affected_world_state["street_blockaded"] = true
		sprite.visible = true
		SceneManager.show_dialog("Jalan berhasil ditutup dengan garis polisi!")
		#HUD.show_message(result.get("message", ""))
		# Don't queue_free — barrier stays visible

extends VideoStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.play()
	await self.finished
	SceneManager.transition_to_scene("res://scenes/levels/main_street.tscn")
	StoryOrchestrator.is_active = true
	if StoryOrchestrator.is_active and not StoryOrchestrator.npc_is_travelling and StoryOrchestrator.get_current_action() != "":
		StoryOrchestrator.start_npc_travel()
		GameState.start_bomb_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

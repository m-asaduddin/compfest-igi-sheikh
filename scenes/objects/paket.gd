extends InteractiveObject

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	requires_inventory = false
	super._ready()
func interact() -> void:
	StoryOrchestrator.player_affected_world_state["paket_swapped"] = true
	print("paket berhasil ditukar!")
	SceneManager.show_dialog("Paket Berhasil ditukar!")
	#HUD.show_message("Paket berhasil ditukar!")

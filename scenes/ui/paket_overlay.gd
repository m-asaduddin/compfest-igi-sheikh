extends Overlay

@onready var boxUpper = $BoxUpper
@onready var boxUpper2 = $BoxUpper2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _button_action():
	StoryOrchestrator.player_affected_world_state["paket_swapped"] = !StoryOrchestrator.player_affected_world_state["paket_swapped"]
	var pos = boxUpper.position
	boxUpper.position = boxUpper2.position
	boxUpper2.position = pos

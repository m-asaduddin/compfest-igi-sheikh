extends Interactable

@export_file("*.tscn") var target_scene_path: String
@export var target_scene_name: String

func interact() -> void:
	get_tree().change_scene_to_file(target_scene_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.:

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labelNode.text = "Press [E] to go to " + target_scene_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

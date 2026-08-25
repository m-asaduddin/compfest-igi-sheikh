extends Interactable

@export_file("*.tscn") var target_scene: String
@export var target_scene_name: String

## Marker2D Node's name in target scene as a spawn pointT
## 
## To set the player spawn point in the target scene, 
## make sure the target scene has `Marker2D` Node.
## Then pass the Marker2D Node's name here
@export var spawn_point_id: String

func interact() -> void:
	GameState.scene_entrance_spot = spawn_point_id
	SceneManager.transition_to_scene(target_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.:

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labelNode.text = "Press [E] to go to " + target_scene_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

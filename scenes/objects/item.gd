extends Interactable

@export var item_name: String
@export var texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = texture
	labelNode.text = "Press [E] to pick up " + item_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact() -> void:
	States.add_item(item_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.:

extends Interactable

@export var item_name: String
@export var texture: Texture2D
var item_id: String

func _ready() -> void:
	item_id = item_name.to_lower().replace(" ", "_")
	if States.inventories.has(item_id):
		queue_free()
	sprite.texture = texture
	labelNode.text = "Press [E] to pick up " + item_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func interact() -> void:
	if not States.inventories.has(item_id):
		States.add_item(item_id)
		queue_free()
	

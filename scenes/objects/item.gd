extends Interactable

@export var item_name: String
@export var texture: Texture2D
var item_id: String

func _ready() -> void:
	item_id = item_name.to_lower().replace(" ", "_")
	if find_child("SaveableItem"):
		var child : SaveableItem = get_node("SaveableItem")
		child.load_save_data(SaveManager.save_state)
	
	if States.inventories.has(item_id):
		queue_free()
	sprite.texture = texture
	labelNode.text = "Press [E] to pick up " + item_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func interact() -> void:
	collect()
	

func collect(no_noise = false, bypass_inventory = false):
	if find_child("SaveableItem"):
		var child : SaveableItem = get_node("SaveableItem")
		child.collect()
		
		
	
	if not States.inventories.has(item_id) or bypass_inventory:
		States.add_item(item_id)
	
	
	queue_free()
	

extends Interactable
class_name Item

@export var item_name: String
@export var texture: Texture2D
var item_id : String = ""

func _ready() -> void:
	item_id = item_name.to_lower().replace(" ", "_")
	if find_child("SaveableItem"):
		var child : SaveableItem = get_node("SaveableItem")
		child.load_save_data(SaveManager.save_state)
	
	if GameState.inventories.has(item_id):
		disappear()
	sprite.texture = texture
	labelNode.text = "Press [E] to pick up " + item_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func interact() -> void:
	await player.play_grab_animation()
	collect()
	

func collect(no_noise = false, bypass_inventory = false):
	print("item.gd: item collected")
	if find_child("SaveableItem"):
		var child : Saveable = get_node("SaveableItem")
		child.collect()
	else:
		if not GameState.inventories.has(item_id) or bypass_inventory:
			GameState.add_item(item_id)
	itemList.add_item(item_name, texture)
	disappear()
	
func disappear():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED

	

extends Interactable
class_name Item

@export var data: ItemData

func _ready() -> void:
	if data == null:
		push_error("Item '%s' has no ItemData resource assigned!" % name)
		return
	if find_child("SaveableItem"):
		var child: SaveableItem = get_node("SaveableItem")
		child.load_save_data(SaveManager.save_state)

	if _has_id_in_inventory():
		disappear()
	sprite.texture = data.texture
	labelNode.text = "[E] AMBIL " + data.name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func interact() -> void:
	await player.play_grab_animation()
	collect()


func collect(no_noise = false, bypass_inventory = false):
	print("item.gd: item collected")
	if find_child("SaveableItem"):
		var child: Saveable = get_node("SaveableItem")
		child.collect()
	else:
		if not _has_id_in_inventory() or bypass_inventory:
			GameState.add_item(data.id)
	SceneManager.add_item(data.name, data.texture)
	disappear()

func disappear():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED

## Returns true if this item's id is already present in the player's inventory.
func _has_id_in_inventory() -> bool:
	for item in GameState.inventories:
		if item.id == data.id:
			return true
	return false

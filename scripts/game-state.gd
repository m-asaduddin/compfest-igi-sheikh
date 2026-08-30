extends Node

var inventories: Array[ItemData] = []
var selected_item: ItemData = null
var current_scene: String = ""
var scene_entrance_spot: String = ""
var time: int = 0
var interaction_target: Node = null
var is_inventory_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

## Load an ItemData resource from the items directory by its id.
func _load_item_resource(id: String) -> ItemData:
	var path = "res://items/%s.tres" % id
	if not ResourceLoader.exists(path):
		push_error("GameState: ItemData resource not found at '%s'" % path)
		return null
	var res = load(path)
	if res is ItemData:
		return res
	push_error("GameState: Resource at '%s' is not an ItemData" % path)
	return null

## Returns true if an item with the given id is already in the inventory.
func _has_item(id: String) -> bool:
	for item in inventories:
		if item.id == id:
			return true
	return false

## Returns the index of the first item matching the given id, or -1.
func _find_item_index(id: String) -> int:
	for i in inventories.size():
		if inventories[i].id == id:
			return i
	return -1

func add_item(id: String) -> void:
	if _has_item(id):
		return
	var item_res = _load_item_resource(id)
	if item_res == null:
		return
	inventories.append(item_res)
	print("added to inventory:", item_res.name)

func use_item(id: String) -> void:
	var idx = _find_item_index(id)
	if idx != -1:
		inventories.remove_at(idx)
		SceneManager.remove_item(idx)
	if selected_item != null and selected_item.id == id:
		selected_item = null
	is_inventory_open = false
	interaction_target = null
	print("used item:", id)

func select_item(index: int) -> void:
	if index < 0 or index >= inventories.size():
		print("invalid inventory index: ", index)
		return
	var item = inventories[index]
	selected_item = item
	print("selected item:\n index:", index, ", name:", item.name)
	if interaction_target != null:
		# Player is interacting with an object — let the object decide the outcome
		InteractionService.combine_with_item(item)
	else:
		# Just browsing inventory — close it without consuming the item
		selected_item = null

func remove_selected() -> void:
	selected_item = null

func game_over():
	SceneManager.transition_to_scene("res://scenes/ui/game_over.tscn")

func get_save_data() -> Dictionary:
	return {
		"inventory_ids": inventories.map(func(i): return i.id),
		"selected_item_id": selected_item.id if selected_item != null else "",
		"current_scene": current_scene,
	}

func load_save_data(data: Dictionary) -> void:
	inventories.clear()
	for id in data.get("inventory_ids", []):
		add_item(str(id))

	var sel_id = data.get("selected_item_id", "")
	if sel_id != "":
		var idx = _find_item_index(sel_id)
		selected_item = inventories[idx] if idx != -1 else null
	else:
		selected_item = null

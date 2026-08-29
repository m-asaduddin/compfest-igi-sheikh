extends Node

var inventories: Array[String] = []
var selected_item: Dictionary = {}
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
	
func add_item(id: String) -> void:
	if inventories.has(id):
		return
	inventories.append(id)
	print("added to inventory:", id)
	
func use_item(id: String) -> void:
	if inventories.has(id):
		#var idx = inventories.find(id)
		inventories.erase(id)
		#SceneManager.remove_item(idx)
	if selected_item.get("id", "") == id:
		selected_item = {}
	is_inventory_open = false
	interaction_target = null
	print("used item:", id)

func select_item(index: int) -> void:
	if index < 0 or index >= inventories.size():
		print("invalid inventory index: ", index)
		return
	var item_id = inventories[index]
	selected_item = {"index": index, "id": item_id}
	print("selected item:\n index:", index, ", name:", item_id)
	InteractionService.combine_with_item(item_id)
	use_item(item_id)

func remove_selected() -> void:
	selected_item = {}

func game_over():
	SceneManager.transition_to_scene("res://scenes/ui/game_over.tscn")
	
func get_save_data() -> Dictionary:
	return {
		"inventories": inventories,
		"selected_item": selected_item,
		"current_scene": current_scene,
	}

func load_save_data(data: Dictionary) -> void:
	var raw_inventory = data.get("inventories", [])
	inventories.clear()
	for item in raw_inventory:
		inventories.append(str(item))
		
	selected_item = data.get("selected_item", {})
	#player_spawn_id = data.get("player_spawn_id", "")

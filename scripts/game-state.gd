extends Node

var inventories: Array[String]

var selected_item : Dictionary = {}
var current_scene : String = ""
var scene_entrance_spot : String = ""
var time : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass
	
func add_item(id: String) -> void:
	inventories.append(id)
	print("added to inventory:", id)
	
func use_item(id: String) -> void:
	inventories.erase(id)

func select_item(index: int) -> void:
	var item_name = inventories[index]
	selected_item.assign({index: item_name})
	print("selected item:\n index:", index, ", name:", item_name)

func remove_selected() -> void:
	selected_item.assign({})

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

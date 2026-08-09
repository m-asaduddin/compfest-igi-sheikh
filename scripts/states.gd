extends Node

@onready var inventories: Array[String]
var selected_item : Dictionary = {}
var player_spawn_id: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")

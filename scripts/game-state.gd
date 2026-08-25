extends Node
var routes = {
	"base":{
		"paket_a":{
			"jalan_x":"death_explosion",
			"jalan_gng":{
				"base": "enprisonment_2",
				"dog": "success"
			}
		},
		"paket_b":{
			"jalan_x": "enprisonment_1",
			"jalan_gng": "enprisonment_2"
		}
	}
}
var route_times = { 
	"base": {
		"mc_house": 20,
		"mc_gudang": 20,
		"base_proceed":20
	},
	"paket_a":{
		"ambil_paket": 20,
		"antar_paket_1": 20,
		"paket_proceeding": 20
	},
	"jalan_x": {
		"antar_paket_x":20
	},
	"jalan_gng": {
		"antar_paket_start":10, #disini, cmn bisa diakses saat paket A tidak ditukar
		"antar_paket_proceeding": 20
	},
	"paket_b":{
		"ambil_paket":20,
		"antar_paket_1":20,
		"paket_proceeding":20,
	},
	
	
}
var route_traversal = []
var current_route : String = ""
var current_npc_action : String = ""
var next_choice = []


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

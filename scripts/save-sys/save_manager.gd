extends Node
var save_nodes = {} #{'{id}': (Saveable)X,...}
var save_state = {} #{'{id}': (Dictionary)dict,...}

func register_saveable(saveable: Saveable) -> void:
	save_nodes[saveable.unique_id] = saveable
	
	if save_state.has(saveable.unique_id):
		saveable.load_save_data(save_state[saveable.unique_id])
	
	save_state["player_state"] = States.get_save_data()

func unregister_saveable(saveable: Saveable) -> void:
	save_nodes.erase(saveable.unique_id)

func capture_current_scene_state() -> void:
	for id in save_nodes:
		var saveable = save_nodes[id]
		save_state[id] = saveable.get_save_data()

func save_to_disk(filepath: String = "user://game_save.json") -> void:
	capture_current_scene_state()
	var state_savedat : Dictionary = States.get_save_data()
	save_state["player_state"] = state_savedat
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_state, "\t"))
		print("Saved to "+filepath)
		print(save_state)

func load_from_disk(filepath: String = "user://game_save.json") -> void:
	if not FileAccess.file_exists(filepath):
		return
	var file = FileAccess.open(filepath, FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) == OK:
		print("Successfully loaded from "+filepath)
		save_state = json.data
		
		if save_state.has("player_state"):
			States.load_save_data(save_state["player_state"])
		
		for id in save_nodes:
			if save_state.has(id):
				save_state[id].load_save_data(save_state[id])
	else:
		print("No save file found in "+filepath)


func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass

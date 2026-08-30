extends Node

var player_affected_world_state = {
	"paket_swapped" = false,
	"street_blockaded" = false, # ini biar ke gang pas jl ke rumah2
	"dog_unleashed" = false,
}
var routes = {
	"base": {
		"paket_a": {
			"jalan_x": "death_explosion",
			"jalan_gng": {
				"base": "enprisonment_2",
				"dog": "success"
			}
		},
		"paket_b": {
			"jalan_x": "enprisonment_1",
			"jalan_gng": "enprisonment_2"
		}
	}
}
var npc_route_actions = {
	#base: awal awal
	#rumah -> ke gudang ambil paket -> exit
	"base": ["mc_house", "mc_gudang", "base_proceed"],
	#paket a: pas ambil paket pertama
	# awal_paket_a dianter, masuk ke rumah 1, proceed paket
	"paket_a": ["ambil_paket", "antar_paket_1", "paket_proceeding"],
	#jalan x: pas menuju ke rumah 2
	"jalan_x": ["antar_paket_x"],
	"jalan_gng": ["antar_paket_start", "antar_paket_proceeding"],
	
	"paket_b": ["ambil_paket", "antar_paket_1", "paket_proceeding"],
}
var time_values = {
	"mc_house": 9, "mc_gudang": 10, "base_proceed": 10,
	"ambil_paket": 15, "antar_paket_1": 5, "paket_proceeding": 5,
	"antar_paket_x": 30,
	"antar_paket_start": 15, "antar_paket_proceeding": 3,
	
}

var _item_interaction = {
	"street": {
		"police-line": {
			"success": true,
			"message": "Jalan Utama Berhasil di Tutup"
		},
		"tang": {
			"success": false,
			"message": "Tidak dapat mengguakan Tang di sini"
		},
		"gunting": {
			"success": false,
			"message": "Aneh rasanya jika menggunakan gunting tanpa alasan"
		}
	},
	"dog_leash": {
		"police-line": {
			"success": false,
			"message": "Anjing ini tidak perlu ditambah garis polisi"
		},
		"tang": {
			"success": false,
			"message": "Tidak bisa menggunakan tang, perlu alat pemotong yg lebih tajam"
		},
		"gunting": {
			"success": true,
			"message": "Tali Anjing berhasil di potong"
		}
	},
	"bomb_wire": {
		"police-line": {
			"success": false,
			"message": "Tidak perlu garis polisi. BOMB INI AKAN MELEDAK!"
		},
		"tang": {
			"success": true,
			"message": ""
		},
		"gunting": {
			"success": false,
			"message": "Butuh alat yang lebih kuat untuk memotong kabel ini"
		}
	}
}

var current_branch: String = "base"
var action_index: int = 0
var action_timer: float = 0.0
var is_active: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_active:
		return
	# Get the sequence array for our current active block
	var current_sequence: Array = npc_route_actions[current_branch]
	
	if action_index < current_sequence.size():
		var current_action = current_sequence[action_index]
		var max_duration = time_values[current_action]
		
		action_timer += delta
		
		# Optional: Emit signal to update UI timer bars or NPC position here
		
		if action_timer >= max_duration:
			print("Finished action: ", current_action)
			resolve_action_completion(current_action)
	else:
		# We finished all actions in this sub-path block, decide where to branch next
		evaluate_next_branch()

func start():
	is_active = true


func resolve_action_completion(action_name: String) -> void:
	# Reset timer for the next step
	action_timer = 0.0
	action_index += 1
	
	# Handle unique context exceptions mid-path
	if action_name == "base_proceed":
		# End of 'base' block: branches to paket_a or paket_b
		if player_affected_world_state["paket_swapped"]:
			switch_to_branch("paket_b")
		else:
			switch_to_branch("paket_a")

	elif action_name == "paket_proceeding":
		# End of packages blocks: check where they go next based on player choice
		# (e.g. choice of road made by environmental blocks or distractions)
		if player_affected_world_state["street_blockaded"]:
			switch_to_branch("jalan_gng")
		else:
			switch_to_branch("jalan_x")
			
	elif action_name == "antar_paket_x" or action_name == "antar_paket_proceeding":
		evaluate_story_ending()

func switch_to_branch(new_branch: String) -> void:
	current_branch = new_branch
	action_index = 0
	action_timer = 0.0
	print("NPC moved to story branch: ", current_branch)

func evaluate_next_branch() -> void:
	# Fallback transition helper if sequences naturally run out of indexes
	if current_branch == "base":
		switch_to_branch("paket_b" if player_affected_world_state["paket_swapped"] else "paket_a")

func evaluate_story_ending() -> void:
	is_active = false
	print("Timeline finished processing. Calculating ending layout...")
	
	# Determine sequence choices
	var chosen_package = "paket_b" if player_affected_world_state["paket_swapped"] else "paket_a"
	var chosen_road = "jalan_gng" if player_affected_world_state["street_blockaded"] else "jalan_x"
	
	var package_dict = routes["base"][chosen_package]
	var final_outcome = package_dict[chosen_road]
	
	# Check if final outcome branches further down into dictionary sub-objects (like jalan_gng)
	if typeof(final_outcome) == TYPE_DICTIONARY:
		if player_affected_world_state["dog_unleashed"] and final_outcome.has("dog"):
			final_outcome = final_outcome["dog"]
		else:
			final_outcome = final_outcome["base"]
			
	trigger_ending_cutscene(final_outcome)

func trigger_ending_cutscene(outcome_name: String) -> void:
	print("GAME OVER OUTCOME TRIGGERED: ", outcome_name)
	# route_times outputs: "death_explosion", "success", "enprisonment_1", etc.
	# Call your Scene Manager transition framework here!

func resolve(object_id: String, item_id: String) -> Dictionary:
	var object_map = _item_interaction.get(object_id, {})
	if object_map.has(item_id):
		return object_map[item_id]
	return {
		"success": false,
		"message": "Tidak ada kombinasi yang cocok. object id: " + object_id + " item id:" + item_id,
	}

func change_world_state(object_id: String):
	match object_id:
		"street" :
			player_affected_world_state["street_blockaded"] = true
			#var blokade_place = get_node("MainStreet/Blokade_place")
			#var texture = load("res://assets/sprites/levels/police-line-set.png")
			#var blokade = Sprite2D.new()
			#blokade.texture = texture
			#blokade.position.x = blokade_place
		"dog_leash":
			player_affected_world_state["dog_unleashed"] = true
	SceneManager.toggle_inventory()

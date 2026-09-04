extends Node

var player_affected_world_state = {
	"paket_swapped": false,
	"street_blockaded": false,
	"dog_unleashed": false,
	"paket_dropped": false,
	"paket_dropped_x": 0.0,
	"paket_dropped_y": 0.0,
	"chase_active": false,
	"chase_timer": 0.0,
	"npc_start_flee_x": 0.0,
	"dog_start_chase_x": 0.0,
	"npc_chase_x": 0.0,
	"dog_chase_x": 0.0,
	"npc_fled": false
}

var npc_route_actions = {
	"base": ["mc_house", "mc_gudang", "base_proceed"],
	#paket a: pas ambil paket pertama
	# awal_paket_a dianter, masuk ke rumah 1, proceed paket
	"paket_a": ["ambil_paket", "antar_paket_1", "paket_proceeding"],
	#jalan x: pas menuju ke rumah 2
	"jalan_x": ["antar_paket_x"],
	"jalan_gng": ["antar_paket_start", "antar_paket_2", "antar_paket_proceeding"],
	
	"paket_b": ["ambil_paket", "antar_paket_1", "paket_proceeding"],
}

var time_values = {
	# Formula: time_value = run_speed(200) / pixel_distance
	# mc_home: NPCStartSpot(122) -> Portal(1947) = 1825px
	"mc_house": 0.1096,
	# main_street: mc_home door(368) -> portal_warehouse(3660) = 3292px
	"mc_gudang": 0.0607,
	# warehouse: antar_paket_1(17) -> ambil_paket(2111) = 2094px
	"base_proceed": 0.0955,
	# warehouse: ambil_paket(2111) -> antar_paket_1(17) = 2094px
	"ambil_paket": 0.0955,
	# main_street: SpawnFromWarehouse(3780) -> home_1(11593) = 7813px
	"antar_paket_1": 0.0256,
	# main_street: home_1(11593) -> paket_proceeding(11887) = 294px
	"paket_proceeding": 0.680,
	# main_street: paket_proceeding(11887) -> antar_paket_x(27631) = 15744px
	"antar_paket_x": 0.0127,
	# main_street: paket_proceeding(11887) -> portal_gang_2_start(14679) = 2792px
	"antar_paket_start": 0.0716,
	# gang_melati: SpawnLeft(310) -> antar_paket_start(5148) = 4838px
	"antar_paket_2": 0.0413,
	# main_street: SpawnFromGang2End(28032) -> antar_paket_x(27631) = 401px
	"antar_paket_proceeding": 0.499,
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
	"dog": {
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
var is_active: bool = false

var npc_progress: float = 0.0 # 0.0 (awal jalur) sampai 1.0 (sampai tujuan)
var npc_is_travelling: bool = false

func _ready() -> void:
	if is_active and not npc_is_travelling and get_current_action() != "":
		start_npc_travel()

func _process(delta: float) -> void:
	# Handle background chase calculation if dog chase is active
	if player_affected_world_state.get("chase_active", false):
		var chase_timer: float = player_affected_world_state.get("chase_timer", 0.0) + delta
		player_affected_world_state["chase_timer"] = chase_timer
		
		var npc_start_x: float = player_affected_world_state.get("npc_start_flee_x", 0.0)
		var dog_start_x: float = player_affected_world_state.get("dog_start_chase_x", 0.0)
		
		# NPC runs left at 200 px/s
		var current_npc_x: float = npc_start_x - (200.0 * chase_timer)
		# Dog starts running left 2 seconds after detection at 280 px/s
		var dog_chase_time: float = max(0.0, chase_timer - 2.0)
		var current_dog_x: float = dog_start_x - (280.0 * dog_chase_time)
		
		player_affected_world_state["npc_chase_x"] = current_npc_x
		player_affected_world_state["dog_chase_x"] = current_dog_x
		
		# If both NPC and Dog run far off left edge of scene (< -100 px), mark chase complete and npc_fled
		if current_npc_x <= -100.0 and current_dog_x <= -100.0:
			player_affected_world_state["chase_active"] = false
			player_affected_world_state["npc_fled"] = true

	# Simulasi latar belakang terus berjalan meski Player di scene manapun
	if npc_is_travelling and not player_affected_world_state.get("chase_active", false) and not player_affected_world_state.get("npc_fled", false):
		# Check if the NPC is physically active in the current scene
		var npc_in_scene = get_tree().get_first_node_in_group("NPC")
		var npc_is_active = npc_in_scene and npc_in_scene.visible
		if not npc_is_active:
			npc_progress += delta * time_values.get(get_current_action(), 0.0)
			
			# Jika NPC sudah sampai di tujuan di latar belakang
			if npc_progress >= 1.0:
				npc_progress = 1.0
				npc_is_travelling = false
				resolve_action_completion(get_current_action())

func start_npc_travel() -> void:
	npc_progress = 0.0
	npc_is_travelling = true

# Mengambil nama aksi cerita yang sedang aktif
func get_current_action() -> String:
	var sequence: Array = npc_route_actions.get(current_branch, [])
	if action_index < sequence.size():
		return sequence[action_index]
	return ""

# Dipanggil saat NPC telah sampai di portal untuk memajukan alur cerita
func resolve_action_completion(completed_action_name: String) -> void:
	print("[STORY ORCHESTRATION] current action: ", get_current_action(), completed_action_name)
	if completed_action_name != get_current_action():
		return
		
	print("Aksi selesai: ", completed_action_name)
	action_index += 1
	
	var sequence: Array = npc_route_actions.get(current_branch, [])
	if action_index >= sequence.size():
		evaluate_next_branch()
		
	if get_current_action() != "":
		start_npc_travel()
	else:
		npc_is_travelling = false

func evaluate_next_branch() -> void:
	if current_branch == "base":
		switch_to_branch("paket_b" if player_affected_world_state["paket_swapped"] else "paket_a")
	elif current_branch == "paket_a" or current_branch == "paket_b":
		switch_to_branch("jalan_gng" if player_affected_world_state["street_blockaded"] else "jalan_x")

func switch_to_branch(new_branch: String) -> void:
	current_branch = new_branch
	action_index = 0
	print("Berpindah ke branch: ", current_branch)

func resolve(object_id: String, item_id: String) -> Dictionary:
	var object_map = _item_interaction.get(object_id, {})
	if object_map.has(item_id):
		return object_map[item_id]
	return {
		"success": false,
		"message": "Tidak bisa menggunakan " + item_id + " di sini",
	}

extends Node

var player_affected_world_state = {
	"paket_swapped" = false,
	"street_blockaded" = false,
	"dog_unleashed" = false
}

var npc_route_actions = {
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
	"mc_house": 0.14, "mc_gudang": 0.12, "base_proceed": 0.15,
	"ambil_paket": 0.15, "antar_paket_1": 0.05, "paket_proceeding": 0.1,
	"antar_paket_x": 0.01,
	"antar_paket_start": 0.05, "antar_paket_proceeding": 0.2,
}

var current_branch: String = "base"
var action_index: int = 0
var is_active: bool = true

var npc_progress: float = 0.0 # 0.0 (awal jalur) sampai 1.0 (sampai tujuan)
var npc_is_travelling: bool = false

func _ready() -> void:
	if is_active and not npc_is_travelling and get_current_action() != "":
		start_npc_travel()

func _process(delta: float) -> void:
	# Simulasi latar belakang terus berjalan meski Player di scene manapun
	if npc_is_travelling:
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

func switch_to_branch(new_branch: String) -> void:
	current_branch = new_branch
	action_index = 0
	print("Berpindah ke branch: ", current_branch)

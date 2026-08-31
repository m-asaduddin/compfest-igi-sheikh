extends Node

var player_affected_world_state = { 
	"paket_swapped" = false, 
	"street_blockaded" = false, 
	"dog_unleashed" = false 
}

var npc_route_actions = {
	"base": ["mc_house", "mc_gudang", "base_proceed"],
	"paket_a": ["ambil_paket", "antar_paket_1", "paket_proceeding"]
}

var current_branch: String = "base"
var action_index: int = 0
var is_active: bool = true

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

func evaluate_next_branch() -> void:
	if current_branch == "base":
		switch_to_branch("paket_b" if player_affected_world_state["paket_swapped"] else "paket_a")

func switch_to_branch(new_branch: String) -> void:
	current_branch = new_branch
	action_index = 0
	print("Berpindah ke branch: ", current_branch)

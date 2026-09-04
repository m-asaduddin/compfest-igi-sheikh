# level_scene.gd
class_name LevelScene
extends Node2D

const DROPPED_PAKET_SCENE = preload("res://scenes/objects/dropped_paket.tscn")

@onready var player = $Player

func _ready() -> void:
	# 1. Simpan informasi scene saat ini di GameState
	GameState.current_scene = scene_file_path
	
	# 2. Proses objek tersimpan
	process_saveables()
	
	# 3. Restore dropped paket if it was dropped on this scene
	_restore_dropped_paket()
	
	# 4. Pindahkan player ke spawn point tujuan
	if GameState.scene_entrance_spot != "":
		var spawn_marker: Marker2D = find_child(GameState.scene_entrance_spot, true, false)
		if spawn_marker and (spawn_marker is Marker2D):
			player.global_position = spawn_marker.global_position

func _restore_dropped_paket() -> void:
	if scene_file_path == "res://scenes/levels/main_street.tscn" or name == "MainStreet":
		if StoryOrchestrator.player_affected_world_state.get("paket_dropped", false):
			var existing_paket = find_child("DroppedPaket*", true, false)
			if not existing_paket:
				var paket_pos_x = StoryOrchestrator.player_affected_world_state.get("paket_dropped_x", 0.0)
				var paket_pos_y = StoryOrchestrator.player_affected_world_state.get("paket_dropped_y", 0.0)
				var paket_instance = DROPPED_PAKET_SCENE.instantiate()
				add_child(paket_instance)
				paket_instance.global_position = Vector2(paket_pos_x, paket_pos_y)

func process_saveables():
	for child in find_children("*", "Saveable", true, false):
		if child is Saveable:
			var saveable_name = child.unique_id
			var saveable_data = SaveManager.save_state.get(saveable_name, null)
			if saveable_data != null:
				child.load_save_data(saveable_data)


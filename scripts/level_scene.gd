# level_scene.gd
class_name LevelScene
extends Node2D

@onready var player = $Player

func _ready() -> void:
	# 1. Simpan informasi scene saat ini di GameState
	GameState.current_scene = scene_file_path
	
	# 2. Proses objek tersimpan
	process_saveables()
	
	# 3. Pindahkan player ke spawn point tujuan
	if GameState.scene_entrance_spot != "":
		var spawn_marker: Marker2D = find_child(GameState.scene_entrance_spot, true, false)
		if spawn_marker and (spawn_marker is Marker2D):
			player.global_position = spawn_marker.global_position

func process_saveables():
	for child in find_children("*", "Saveable", true, false):
		if child is Saveable:
			var saveable_name = child.unique_id
			var saveable_data = SaveManager.save_state.get(saveable_name, null)
			if saveable_data != null:
				child.load_save_data(saveable_data)

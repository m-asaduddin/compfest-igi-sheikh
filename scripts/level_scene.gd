class_name LevelScene
extends Node2D

@onready var player = $Player

func process_saveables():
	for child in find_children("*", "Saveable", true, false):
		print(child.name)
		if child is Saveable:
			var saveable_name = child.unique_id
			print("processing ", saveable_name)
			var saveable_data = SaveManager.save_state.get(saveable_name, null)
			print(saveable_data)
			if saveable_data != null:
				child.load_save_data(saveable_data)
				print("Loaded save for ", saveable_name, saveable_data)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_saveables()
	if GameState.scene_entrance_spot != "":
		var spawn_marker: Marker2D = find_child(GameState.scene_entrance_spot, true, false)
		if spawn_marker and (spawn_marker is Marker2D):
			player.global_position = spawn_marker.global_position




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

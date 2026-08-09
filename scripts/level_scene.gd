class_name LevelScene
extends Node2D

@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if States.player_spawn_id != "":
		var spawn_marker: Marker2D = find_child(States.player_spawn_id, true, false)
		if spawn_marker and (spawn_marker is Marker2D):
			player.global_position = spawn_marker.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

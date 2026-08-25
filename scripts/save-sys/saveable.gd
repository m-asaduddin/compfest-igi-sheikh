class_name Saveable
extends Node

@export var unique_id: String = ""

func _ready() -> void:
	if unique_id.is_empty():
		# Uses parent path + node name as fallback
		unique_id = get_parent().get_path()
	
	#SaveManager.register_saveable(self)

func get_save_data() -> Dictionary:
	return {}

func load_save_data(_data: Dictionary) -> void:
	pass

func _exit_tree() -> void:
	#SaveManager.unregister_saveable(self)
	pass

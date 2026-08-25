extends Saveable
class_name SaveableItem

@export var destroy_if_collected: bool = true

var is_collected: bool = false
#@Override
func get_save_data() -> Dictionary:
	return {
		"is_collected": is_collected
	}

#@Override
func load_save_data(data: Dictionary) -> void:
	is_collected = data.get("is_collected", false)
	
	if is_collected and destroy_if_collected:
		get_parent().queue_free()

func collect() -> void:
	is_collected = true
	SaveManager.capture_current_scene_state()
	get_parent().queue_free()

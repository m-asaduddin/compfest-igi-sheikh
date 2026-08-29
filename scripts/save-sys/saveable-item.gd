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
		get_parent().visible = false
		get_parent().process_mode = Node.PROCESS_MODE_DISABLED

func collect(no_noise = true, bypass_inventory_exclusive = false) -> void:
	is_collected = true
	SaveManager.register_saveable(self)
	print("saveable-item.gd: Collected")
	add_to_inventory()
	SaveManager.capture_current_scene_state()
	disappear()
	
func add_to_inventory(bypass_inventory_exclusive = false):
	if not GameState.inventories.has(unique_id) or bypass_inventory_exclusive:
		GameState.add_item(unique_id)
		
	
	

func disappear():
	get_parent().visible = false
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	
func _ready() -> void:
	#SaveManager.register_saveable(self)
	pass

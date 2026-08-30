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
	# Get the ItemData from the parent Item node
	var item_data: ItemData = get_parent().data
	if item_data == null:
		push_error("SaveableItem: parent has no ItemData resource assigned!")
		return
	if not GameState._has_item(item_data.id) or bypass_inventory_exclusive:
		GameState.add_item(item_data.id)

	

func disappear():
	get_parent().visible = false
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	
func _ready() -> void:
	#SaveManager.register_saveable(self)
	pass

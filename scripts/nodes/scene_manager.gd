extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var _inventory: Control = $Inventory
@onready var _inventoryItemList: ItemList = $Inventory/ItemList


func transition_to_scene(target_scene_path: String, is_loading_save: bool = false) -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	if get_tree().current_scene:
		get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	
	anim_player.play("LoadIn")
	await anim_player.animation_finished
	
	if not is_loading_save and get_tree().current_scene.name != "MainMenu":
		SaveManager.capture_current_scene_state()
	
	if is_loading_save:
		SaveManager.load_from_disk()
	
	get_tree().change_scene_to_file(target_scene_path)
	
	await get_tree().process_frame
	
	anim_player.play("LoadOut")
	await anim_player.animation_finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func toggle_inventory():
	GameState.is_inventory_open = !GameState.is_inventory_open
	_inventory.visible = GameState.is_inventory_open
	
func add_item(name: String, texture: Texture2D):
	_inventoryItemList.add_item(name, texture)

func remove_item(idx: int):
	_inventoryItemList.remove_item(idx)
		
		
	
	

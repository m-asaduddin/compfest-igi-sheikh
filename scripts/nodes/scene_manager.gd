extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var _inventory: Control = $Inventory
@onready var _inventoryItemList: ItemList = $Inventory/ItemList
@onready var _dialogBox = $DialogBox

const DIALOG_BOX_SCENE = preload("res://scenes/ui/dialog_box.tscn")

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
	print("inventory open:", _inventory.visible, GameState.is_inventory_open)
	
func add_item(name: String, texture: Texture2D):
	_inventoryItemList.add_item(name, texture)

func remove_item(idx: int):
	_inventoryItemList.remove_item(idx)

func show_dialog(text: String) -> void:
	# 1. Pause seluruh jalannya game
	get_tree().paused = true
	
	# 2. Instantiate scene Dialog Box
	var dialog_instance: DialogBox = DIALOG_BOX_SCENE.instantiate()
	
	# 3. Masukkan ke CanvasLayer agar UI muncul paling depan di atas gameplay
	# (Jika Autoload kamu adalah CanvasLayer, pakai add_child(dialog_instance))
	add_child(dialog_instance)
	
	# 4. Berikan teks pesan yang diinginkan
	dialog_instance.setup(text)
	
	# 5. Hubungkan sinyal dismissed untuk me-resume game saat tombol diklik
	dialog_instance.dismissed.connect(_on_dialog_dismissed)

func _on_dialog_dismissed() -> void:
	# Resume game kembali saat dialog di-dismiss
	get_tree().paused = false
	GameState.is_inventory_open = false
	_inventory.visible = GameState.is_inventory_open

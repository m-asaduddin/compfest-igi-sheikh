extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var _inventory: Control = $Inventory
@onready var _inventoryItemList: ItemList = $Inventory/ItemList
@onready var _dialogBox = $DialogBox
@onready var _bomb_timer: Timer = $BombTimer
@onready var _bomb_overlay = $BombOverlay

const DIALOG_BOX_SCENE = preload("res://scenes/ui/dialog_box.tscn")

# ─────────────────────────────────────────────
#  BOMB COUNTDOWN TIMER
# ─────────────────────────────────────────────
func _ready() -> void:
	_bomb_timer.timeout.connect(_on_bomb_timer_timeout)

func _process(_delta: float) -> void:
	# Keep TimerLabel updated every frame while the timer is running
	if not _bomb_timer.is_stopped() and _bomb_overlay.visible:
		var secs_left: int = int(ceil(_bomb_timer.time_left))
		var mins: int = secs_left / 60
		var secs: int = secs_left % 60
		_bomb_overlay.set_timer_label("%02d:%02d" % [mins, secs])

func start_bomb_timer() -> void:
	_bomb_timer.start(300.0)

func stop_bomb_timer() -> void:
	_bomb_timer.stop()

func _on_bomb_timer_timeout() -> void:
	# Time ran out — bomb explodes
	GameState.bomb_diffused = true
	GameState.diffuse_success = false
	_bomb_overlay.visible = false
	GameState.game_over()

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
	
	
func show_box_overlay() -> void:
	$PaketOverlay.visible = true

func show_opening() -> void :
	print("cutscene displayed")
	var opening_video = $Opening_cutscene
	opening_video.show()
	opening_video.play()
	await opening_video.finished
	opening_video.hide()

func show_ending() -> void :
	var ending_cutscene = $Ending_cutscene
	ending_cutscene.show()
	ending_cutscene.play()
	await ending_cutscene.finished
	ending_cutscene.hide()

func show_computer_overlay() -> void:
	$ScreenOverlay.visible = true

func show_bomb_overlay() -> void:
	$BombOverlay.visible = true
	start_bomb_timer()
	

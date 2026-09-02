extends Control
@onready var newgame_btn : TextureButton = $VBoxContainer/NewGame
@onready var loadgame_btn : TextureButton = $VBoxContainer/Load
@onready var credits_btn : TextureButton = $VBoxContainer/Credits

@export_file("*.tscn") var first_scene : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	newgame_btn.pressed.connect(new_game_pressed)
	loadgame_btn.pressed.connect(continue_pressed)
	credits_btn.pressed.connect(SceneManager.show_ending)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func new_game_pressed():
	SaveManager.save_state.clear()
	GameState.inventories.clear()
	
	await SceneManager.show_opening()
	SceneManager.transition_to_scene(first_scene)
	
	StoryOrchestrator.is_active = true
	if StoryOrchestrator.is_active and not StoryOrchestrator.npc_is_travelling and StoryOrchestrator.get_current_action() != "":
		StoryOrchestrator.start_npc_travel()
	
func continue_pressed():
	if FileAccess.file_exists("user://game_save.json"):
		SceneManager.transition_to_scene(first_scene, true)

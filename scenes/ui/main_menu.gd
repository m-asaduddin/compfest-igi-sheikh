extends Control
@onready var newgame_btn : Button = $VBoxContainer/NewGame
@onready var loadgame_btn : Button = $VBoxContainer/Load
@onready var credits_btn : Button = $VBoxContainer/Credits

@export_file("*.tscn") var first_scene : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	newgame_btn.pressed.connect(new_game_pressed)
	loadgame_btn.pressed.connect(continue_pressed)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func new_game_pressed():
	SaveManager.save_state.clear()
	GameState.inventories.clear()
	
	SceneManager.transition_to_scene(first_scene)
	
func continue_pressed():
	if FileAccess.file_exists("user://game_save.json"):
		SceneManager.transition_to_scene(first_scene, true)

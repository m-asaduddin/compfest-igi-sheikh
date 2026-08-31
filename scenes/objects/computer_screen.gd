extends Interactable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labelText = "[E] BUKA KOMPUTER"
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Called every frame. 'delta' is the elapsed time since the previous frame.:
	pass

func interact() -> void:
	SceneManager.show_computer_overlay()

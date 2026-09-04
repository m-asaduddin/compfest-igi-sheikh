class_name Overlay
extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_texture_button_pressed() -> void:
	get_tree().paused = false
	self.visible = false
	#queue_free()

func _on_button_pressed() -> void:
	_button_action()
	
func _button_action() :
	print("action done")

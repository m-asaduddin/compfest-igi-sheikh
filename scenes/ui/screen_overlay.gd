extends Overlay

@onready var _text_input = $ComputerMonitor/main_screen/LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _button_action():
	var not_found = $ComputerMonitor/main_screen/not_found
	if _text_input.text == "8317136":
		$Button.visible = false
		$ComputerMonitor/main_screen.visible = false
		$ComputerMonitor/wahyudi.visible = true
		not_found.visible = false
	else:
		not_found.visible = true 

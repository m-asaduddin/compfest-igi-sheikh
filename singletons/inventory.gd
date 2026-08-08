extends Node

@onready var inventories: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_item(name: String) -> void:
	inventories.append(name)
	print("added to inventory:", name)
	
func use_item(name: String) -> void:
	inventories.erase(name)

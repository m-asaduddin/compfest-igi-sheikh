extends Area2D

@export var item_name: String

@onready var hud = $Hud
@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D
var player_in_area: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud.visible = false
	var label: Label = hud.get_node("Label")
	label.text = "Press [E] to pick up " + item_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact"):
		interacted()

func interacted() -> void :
	self.remove_child(collision)
	self.remove_child(sprite)
	#self.remove_child(hud)
	hud.visible = false
	Inventory.add_item(item_name)
	

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true
		hud.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		hud.visible = false
		player_in_area = false

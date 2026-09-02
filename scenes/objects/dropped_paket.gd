extends Area2D
class_name DroppedPaket

@onready var label_node: Label = $Label
@onready var collision: CollisionShape2D = $CollisionShape2D

var player_in_area: bool = false

func _ready() -> void:
	label_node.text = "[E] Periksa paket"
	label_node.visible = false

func _input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact"):
		interact()

func interact() -> void:
	SceneManager.show_bomb_overlay()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true
		label_node.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false
		label_node.visible = false

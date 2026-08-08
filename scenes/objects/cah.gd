extends Area2D

@export_file("*.tscn") var target_scene_path: String
@export var target_scene_name: String

@onready var labelNode = $Label
var player_in_area = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labelNode.text = "Pindah ke scene " + target_scene_name
	labelNode.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact"):
		get_tree().change_scene_to_file(target_scene_path)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		labelNode.visible = true
		player_in_area = true
		


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		labelNode.visible = false
		player_in_area = false

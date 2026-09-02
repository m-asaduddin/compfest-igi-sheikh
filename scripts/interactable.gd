@abstract
class_name Interactable
extends Area2D

@onready var labelNode: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision = $CollisionShape2D

var player: Node2D

var player_in_area = false
var labelText: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labelNode.visible = false
	labelNode.text = labelText

@abstract func interact() -> void

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact"):
		await interact()

func _on_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		player = body
		labelNode.visible = true
		player_in_area = true
	if body is NPC and self is Portal:
		_on_npc_entered()
		#print("npc in area")
		#body.hide()


func _on_body_exited(body: CharacterBody2D) -> void:
	if body is Player:
		player = null
		labelNode.visible = false
		player_in_area = false
		
func _on_npc_entered() -> void:
	pass

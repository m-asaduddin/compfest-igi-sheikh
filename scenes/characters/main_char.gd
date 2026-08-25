extends Area2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SaveManager.save_to_disk()
		GameState.game_over()

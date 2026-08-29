extends Node

signal target_set(target)
signal try_combine(item_id)

func set_target(target: Node) -> void:
	GameState.interaction_target = target
	emit_signal("target_set", target)

func combine_with_item(item_id: String) -> void:
	if GameState.interaction_target and GameState.interaction_target.has_method("try_combine_with_item"):
		GameState.interaction_target.try_combine_with_item(item_id)
	else:
		emit_signal("try_combine", item_id)

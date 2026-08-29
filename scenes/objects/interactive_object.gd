extends Interactable
class_name InteractiveObject

@export var object_id: String = ""
@export var interaction_label: String = "Press [E] to interact"
@export var requires_inventory: bool = true
@export var interaction_result_text: String = ""

func _ready() -> void:
	if labelNode:
		labelNode.text = interaction_label
	if object_id == "":
		object_id = name.to_lower().replace(" ", "_")
	if GameState == null:
		return
	print("object_id: ",object_id)

func _process(_delta: float) -> void:
	pass

func interact() -> void:
	if requires_inventory:
		SceneManager.toggle_inventory()
		return
	apply_result({"success": true, "message": interaction_result_text})

func try_combine_with_item(item_id: String) -> void:
	var result = StoryOrchestrator.resolve(object_id, item_id)
	if result.get("success", false):
		if result.get("consumes_item", false):
			GameState.use_item(result.get("used_item", item_id))
		apply_result(result)
		match object_id:
			"street" :
				StoryOrchestrator.player_affected_world_state["street_blockaded"] = true
			"dog_leash":
				StoryOrchestrator.player_affected_world_state["dog_unleashed"] = true
		return
	print(result.get("message", "Tindakan tidak berhasil."))

func apply_result(result: Dictionary) -> void:
	if result.has("message"):
		print(result["message"])
	if result.get("success", false):
		GameState.close_inventory()
		if result.get("remove_object", false):
			queue_free()

func _input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact"):
		interact()

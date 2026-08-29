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
	print("object_id: ", object_id)

func _process(_delta: float) -> void:
	pass

func interact() -> void:
	if requires_inventory:
		# Set target NOW so select_item knows this open came from an object
		GameState.interaction_target = self
		SceneManager.toggle_inventory()
		return

func try_combine_with_item(item_id: String) -> void:
	var result = StoryOrchestrator.resolve(object_id, item_id)
	if result.get("success", false):
		GameState.use_item(item_id)
		apply_result(result)
		StoryOrchestrator.change_world_state(object_id)
		queue_free()
		return
	# Combination failed — item stays in inventory, show feedback
	print(result.get("message", "Tindakan tidak berhasil."))
	GameState.interaction_target = null

func apply_result(result: Dictionary) -> void:
	#if result.has("message"):
		#print(result["message"])
	if result.get("success", false):
		SceneManager.toggle_inventory()
		if result.get("remove_object", false):
			queue_free()
	#pass

func _input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact"):
		interact()

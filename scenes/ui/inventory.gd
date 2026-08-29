extends Control

@onready var item_list: ItemList = $ItemList

func _ready() -> void:
	refresh_inventory(GameState.inventories)
	item_list.item_selected.connect(_on_item_list_item_selected)

func refresh_inventory(items: Array) -> void:
	item_list.clear()
	for item_id in items:
		item_list.add_item(str(item_id))

func _on_item_list_item_selected(index: int) -> void:
	if GameState == null:
		return
	GameState.select_item(index)

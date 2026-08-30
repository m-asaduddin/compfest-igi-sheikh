extends Control

@onready var item_list: ItemList = $ItemList

func _ready() -> void:
	# Refresh the list every time the inventory panel becomes visible
	visibility_changed.connect(_on_visibility_changed)
	# Use item_activated (double-click / Enter) instead of item_selected (single click)
	# so merely highlighting an item doesn't trigger selection
	item_list.item_activated.connect(_on_item_list_item_activated)

func _on_visibility_changed() -> void:
	if visible:
		refresh_inventory(GameState.inventories)

func refresh_inventory(items: Array[ItemData]) -> void:
	item_list.clear()
	for item in items:
		var idx = item_list.add_item(item.name)
		if item.texture:
			item_list.set_item_icon(idx, item.texture)

func _on_item_list_item_activated(index: int) -> void:
	if GameState == null:
		return
	GameState.select_item(index)

func _input(event: InputEvent) -> void:
	if event.is_action("close"):
		GameState.is_inventory_open = false
		self.visible = false

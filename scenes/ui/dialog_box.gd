extends Control
class_name DialogBox

signal dismissed

@onready var message_label: Label = $Label
@onready var dismiss_button: Button = $Button

func _ready() -> void:
	dismiss_button.pressed.connect(_on_dismiss_pressed)

func setup(text: String) -> void:
	message_label.text = text

func _on_dismiss_pressed() -> void:
	dismissed.emit()
	queue_free() # Hapus DialogBox dari memori setelah di-dismiss

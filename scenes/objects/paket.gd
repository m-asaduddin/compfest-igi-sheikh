extends Interactable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labelText = "[E] periksa paket"
	super._ready()

func interact() -> void:
	#self.get_parent().add_child(overlay)
	print("box pressed")
	SceneManager.show_box_overlay()
	#HUD.show_message("Paket berhasil ditukar!")

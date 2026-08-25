extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func transition_to_scene(target_scene_path: String, is_loading_save: bool = false) -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	anim_player.play("LoadIn")
	await anim_player.animation_finished
	
	if not is_loading_save and get_tree().current_scene.name != "MainMenu":
		SaveManager.capture_current_scene_state()
	
	get_tree().change_scene_to_file(target_scene_path)
	
	await get_tree().process_frame
	
	if is_loading_save:
		SaveManager.load_from_disk()
	
	anim_player.play("LoadOut")
	await anim_player.animation_finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

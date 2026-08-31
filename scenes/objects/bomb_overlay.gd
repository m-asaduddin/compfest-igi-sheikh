extends Overlay

# --- Correct sequences ---
const CORRECT_BUTTON_SEQ: Array[int] = [4, 3, 1, 2]
const CORRECT_CABLE_SEQ: Array[String] = ["green", "yellow", "blue", "white"]

# --- State ---
var button_phase_done: bool = false
var cable_index: int = 0          # how many cables have been cut so far
var button_seq_progress: int = 0  # how many correct buttons pressed so far

# --- Lamp node refs (populated in _ready) ---
var lamp_reds: Array[Node] = []
var lamp_greens: Array[Node] = []

# --- Cable node refs ---
const CABLE_ORDER: Array[String] = ["green", "yellow", "blue", "white"]
var connected_cables: Dictionary = {}   # color -> Sprite2D (connected)
var cut_cables: Dictionary = {}         # color -> Sprite2D (cut)

# --- Button node refs (button number -> TextureButton) ---
var buttons: Dictionary = {}

# --- Timer label ref ---
@onready var _timer_label: Label = $TimerLabel

func _ready() -> void:
	# Collect lamp nodes
	var lamps = $Lamps
	lamp_reds = [
		lamps.get_node("LampRed1"),
		lamps.get_node("LampRed2"),
		lamps.get_node("LampRed3"),
		lamps.get_node("LampRed4"),
	]
	lamp_greens = [
		lamps.get_node("LampGreen"),
		lamps.get_node("LampGreen2"),
		lamps.get_node("LampGreen3"),
		lamps.get_node("LampGreen4"),
	]

	# All lamps start red
	_reset_lamps()

	# Collect cable nodes
	var cables = $Cables
	connected_cables = {
		"green":  cables.get_node("CableConnectedGreen"),
		"yellow": cables.get_node("CableConnectedYellow"),
		"blue":   cables.get_node("CableConnectedBlue"),
		"white":  cables.get_node("CableConnectedWhite"),
	}
	cut_cables = {
		"green":  cables.get_node("CableConnectedGreenCut"),
		"yellow": cables.get_node("CableConnectedYellowCut"),
		"blue":   cables.get_node("CableConnectedBlueCut"),
		"white":  cables.get_node("CableConnectedWhiteCut"),
	}

	# Collect buttons (1-9 inside BackgroundBom)
	var bom = $BackgroundBom
	buttons = {
		1: bom.get_node("TextureButton1"),
		2: bom.get_node("TextureButton2"),
		3: bom.get_node("TextureButton3"),
		4: bom.get_node("TextureButton4"),
		5: bom.get_node("TextureButton5"),
		6: bom.get_node("TextureButton6"),
		7: bom.get_node("TextureButton7"),
		8: bom.get_node("TextureButton8"),
		9: bom.get_node("TextureButton9"),
	}

	# Connect button signals
	for num in buttons:
		var btn: TextureButton = buttons[num]
		btn.pressed.connect(_on_number_button_pressed.bind(num))

	# Connect cable click signals
	for color in connected_cables:
		var sprite: Sprite2D = connected_cables[color]
		# We use an Area2D or input detection — cables are Sprite2D so we need input_event
		# Forward input via _input; handled below
		pass

	# Initially cables are not interactable until button phase is done
	_update_cable_interactability()

	# Start the 5-minute countdown as soon as the overlay is ready
	#SceneManager.start_bomb_timer()
	# Show the initial time
	set_timer_label("05:00")

# ─────────────────────────────────────────────
#  TIMER LABEL
# ─────────────────────────────────────────────
func set_timer_label(text: String) -> void:
	if _timer_label:
		_timer_label.text = text

# ─────────────────────────────────────────────
#  INPUT — cable clicking
# ─────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if not button_phase_done:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not GameState._has_item("tang"):
		return  # player must have tang to cut cables

	# Detect which connected cable was clicked
	for color in connected_cables:
		var sprite: Sprite2D = connected_cables[color]
		if not sprite.visible:
			continue
		var local_pos = sprite.get_local_mouse_position()
		var tex_size = sprite.texture.get_size() * 0.5
		if abs(local_pos.x) <= tex_size.x and abs(local_pos.y) <= tex_size.y:
			_on_cable_clicked(color)
			break

# ─────────────────────────────────────────────
#  BUTTON PHASE
# ─────────────────────────────────────────────
func _on_number_button_pressed(num: int) -> void:
	if button_phase_done:
		return

	var expected: int = CORRECT_BUTTON_SEQ[button_seq_progress]
	if num == expected:
		button_seq_progress += 1
		# Light up the next lamp green
		_set_lamp(button_seq_progress - 1, "green")
		if button_seq_progress >= CORRECT_BUTTON_SEQ.size():
			button_phase_done = true
			_update_cable_interactability()
	else:
		# Wrong — reset sequence
		button_seq_progress = 0
		_reset_lamps()

func _reset_lamps() -> void:
	for i in lamp_reds.size():
		lamp_reds[i].visible = true
		lamp_greens[i].visible = false

func _set_lamp(index: int, color: String) -> void:
	if color == "green":
		lamp_reds[index].visible = false
		lamp_greens[index].visible = true
	else:
		lamp_reds[index].visible = true
		lamp_greens[index].visible = false

# ─────────────────────────────────────────────
#  CABLE PHASE
# ─────────────────────────────────────────────
func _update_cable_interactability() -> void:
	# Visual hint: after button phase, cables become "highlighted" / cursor changes, etc.
	# Nothing special needed — the _input check handles it.
	pass

func _on_cable_clicked(color: String) -> void:
	if cable_index >= CORRECT_CABLE_SEQ.size():
		return

	var expected_color: String = CORRECT_CABLE_SEQ[cable_index]

	if color == expected_color:
		# Correct cable — swap to cut sprite
		connected_cables[color].visible = false
		cut_cables[color].visible = true
		cable_index += 1

		if cable_index >= CORRECT_CABLE_SEQ.size():
			_on_bomb_diffused_success()
	else:
		# Wrong cable — bomb explodes
		_on_bomb_explode()

func _on_bomb_diffused_success() -> void:
	GameState.bomb_diffused = true
	GameState.diffuse_success = true
	SceneManager.stop_bomb_timer()
	get_tree().paused = false
	self.visible = false

func _on_bomb_explode() -> void:
	GameState.bomb_diffused = true
	GameState.diffuse_success = false
	get_tree().paused = false
	self.visible = false
	GameState.game_over()

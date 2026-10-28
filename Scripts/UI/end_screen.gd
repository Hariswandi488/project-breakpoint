extends CanvasLayer

@onready var result_label: Label = $Box/ResultLabel
@onready var restart_button: Button = $Box/RestartButton

var game_status = null

func _ready() -> void:
	hide()
	restart_button.pressed.connect(_restart)
	var gm := get_tree().get_first_node_in_group("GameManager")
	gm.game_won.connect(func(): show_result(true))
	gm.game_lost.connect(func(): show_result(false))

func show_result(stat:bool):
	var text = "Menang" if stat else "Kalah"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if stat:
		game_status = true
		result_label.text = text
	elif not stat:
		game_status = false
		result_label.text = text
	show()
	DebugManager.log_debug(self, "GAME", "GAMEOVER", text)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("restart") and game_status != null:
		_restart()

func _restart() -> void:
	get_tree().reload_current_scene()
	DebugManager.log_debug(self, "GAME", "RESTART", "Succes")

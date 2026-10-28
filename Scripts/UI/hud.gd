extends CanvasLayer

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $ProgressBar/Label

var player:CharacterBody3D
var player_health:HealthComponent

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	player_health = player.get_node("HealthComponent")
	player_health.health_changed.connect(_on_change_health)
	
	_on_change_health(player_health.current_health, player_health.max_health)

func _on_change_health(current_hp:int, max_hp:int):
	label.text = "HP " + str(current_hp) + " / " + str(max_hp)
	progress_bar.max_value = float(max_hp)
	progress_bar.value = float(current_hp)

extends Node

signal game_won
signal game_lost

var game_over := false
var enemies_left := 0

func _ready() -> void:
	add_to_group("GameManager")
	var enemies := get_tree().get_nodes_in_group("Enemy")
	enemies_left = enemies.size()
	DebugManager.log_debug(self, "GAME", "ENEMY", "Enemy Left: "+str(enemies_left))
	for e in enemies:
		e.get_node("HealthComponent").died.connect(_on_enemy_died)
	
	var player = get_tree().get_first_node_in_group("Player")
	player.get_node("HealthComponent").died.connect(_on_player_died)

func _on_enemy_died():
	if game_over:
		return
	
	enemies_left -= 1
	DebugManager.log_debug(self, "GAME", "ENEMY", "Enemy Left: "+str(enemies_left))
	if enemies_left <= 0:
		end_game(true)

func _on_player_died():
	if game_over:
		return
	
	end_game(false)

func end_game(won:bool):
	game_over = true
	
	if won:
		game_won.emit()
	else:
		game_lost.emit()

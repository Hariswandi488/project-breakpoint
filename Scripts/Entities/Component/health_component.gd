class_name HealthComponent
extends Node

signal health_changed(current:int, maximum:int)
signal died

@export var parent:Node3D
@export var max_health:int = 200

var current_health:int

func _ready() -> void:
	current_health = max_health

func take_damage(dmg:int):
	if current_health <= 0:
		DebugManager.log_debug(parent, "HEALTH","FAILED", "Already Dead")
		return
		
	current_health = max(current_health - dmg, 0)
	health_changed.emit(current_health, max_health)
	DebugManager.log_debug(parent, "HEALTH", "GETDAMAGE", "%d | HP: %d/%d" % [dmg, current_health, max_health])
	
	if current_health == 0:
		died.emit()
		DebugManager.log_debug(parent, "HEALTH", "INFO", "Dead")

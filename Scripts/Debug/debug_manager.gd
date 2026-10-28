extends Node

var debug_enabled:bool = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		debug_enabled = !debug_enabled
	
		print("[DEBUG] ", "ENABLED" if debug_enabled else "DISABLED")

func log_debug(Entity:Node ,system:String, category:String, message:String):
	if not debug_enabled:
		return
	
	print("[%s] [%s] [%s] %s" % [system, Entity.name, category, message])

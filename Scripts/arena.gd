extends Node3D

func _ready() -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER") and body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_damage(100)

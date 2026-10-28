extends StaticBody3D

@onready var health: HealthComponent = $HealthComponent
@onready var mesh: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	health.health_changed.connect(_on_health_changed)


func _on_health_changed(_current:int, _maximum:int) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	mesh.material_override = mat
	await get_tree().create_timer(0.1).timeout
	mesh.material_override = null

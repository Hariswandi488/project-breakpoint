extends CharacterBody3D

@export var walk_speed:int = 10
@export var sprint_speed:int = 25
@export var jump_velocity:float = 4.5
@export var mouse_sensivitity:float = 0.003

@onready var camera_pivot: Node3D = $CameraPivot
@onready var visual: Node3D = $Visual

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton:
		if event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensivitity)
		
		camera_pivot.rotate_x(-event.relative.y * mouse_sensivitity)
		
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg_to_rad(-60),
			deg_to_rad(0)
		)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (camera_pivot.global_basis * Vector3(input_dir.x, 0, input_dir.y))
	direction.y = 0 if not Input.is_action_just_pressed("jump") else 10
	direction = direction.normalized()
	
	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	if direction.length() > 0.1:
		var target_angel := atan2(direction.x, direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_angel, 10.0 * delta)
	
	move_and_slide()

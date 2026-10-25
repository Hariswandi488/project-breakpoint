extends CharacterBody3D

@export_group("Movement")
@export var walk_speed:int = 10
@export var sprint_speed:int = 25
@export var jump_velocity:float = 4.5
@export var mouse_sensivitity:float = 0.003
@export var attack_deceleration: float = 15.0
@export var dead_deceleration: float = 15.0

@export_group("Combat")
@export var damage: int = 50

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm_3d: SpringArm3D = $CameraPivot/SpringArm3D
@onready var visual: Node3D = $Visual
@onready var state: State = $State
@onready var hit_box: Area3D = $Visual/HitBox
@onready var hitbox_shape: CollisionShape3D = $Visual/HitBox/HitboxShape
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_timer: Timer = $AttackTimer
@onready var health: HealthComponent = $HealthComponent

var already_hits: Array[Node3D] = []
var camera_vertical:float = 0.0

func _ready() -> void:
	add_to_group("Player")
	hitbox_shape.disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health.health_changed.connect(func(c,m): print("HP",c,"/",m))

func _unhandled_input(event: InputEvent) -> void:
	if state.state == state.STATE.DEAD:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	
	if Input.is_action_just_pressed("attack"):
		start_attack()
		
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton:
		if event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	
	if event is InputEventMouseMotion:
		#camera horizontal
		camera_pivot.rotate_y(-event.relative.x * mouse_sensivitity)
		#camera vertical
		camera_vertical -= event.relative.y * mouse_sensivitity
		camera_vertical = clamp(
			camera_vertical,
			deg_to_rad(-60),
			deg_to_rad(0)
		)
		
		spring_arm_3d.rotation.x = camera_vertical
 
func _physics_process(delta: float) -> void:
	handle_movement(delta)

func handle_movement(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if state.state == state.STATE.ATTACK:
		velocity.x = move_toward(
			velocity.x, 0.0, attack_deceleration * delta
		)
		velocity.z = move_toward(
			velocity.z, 0.0, attack_deceleration * delta
		)
	
	elif state.state == state.STATE.DEAD:
		velocity.x = move_toward(
			velocity.x, 0.0, dead_deceleration * delta
		)
		velocity.z = move_toward(
			velocity.z, 0.0, dead_deceleration * delta
		)
	else:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
		
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction := (camera_pivot.global_basis * Vector3(input_dir.x, 0, input_dir.y))
		direction.y = 0
		direction = direction.normalized()
		
		var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		if direction.length() > 0.1: 
			var target_angel := atan2(direction.x, direction.z)
			visual.global_rotation.y = lerp_angle(visual.global_rotation.y, target_angel, 10 * delta)
		
		state.state = state.STATE.MOVE if  direction.length() > 0.1 else state.STATE.IDLE


	move_and_slide()

func start_attack():
	if state.state == state.STATE.ATTACK:
		DebugManager.log_debug(self, "ATTACK", "BLOCK", " Still In Attack State")
		return
	
	if not attack_cooldown.is_stopped():
		DebugManager.log_debug(self, "ATTACK", "BLOCK", "Attack Still CD")
		return
	DebugManager.log_debug(self, "ATTACK", "INFO", "Attack Start")
	already_hits.clear()
	state.state = state.STATE.ATTACK
	attack_timer.start()
	hitbox_shape.disabled = false
	hit_box.monitoring = true

	
func _on_hit_box_body_entered(body: Node3D) -> void:
	if body in already_hits:
		DebugManager.log_debug(self, "ATTACK", "BLOCK", "Body Already In")
		return
	DebugManager.log_debug(self, "ATTACK", "INFO", "Body Dettected")
	already_hits.append(body)
	if body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_damage(damage)

func _on_attack_timer_timeout() -> void:
	attack_cooldown.start()
	hitbox_shape.disabled = true
	hit_box.monitoring = false
	state.state = state.STATE.IDLE
	

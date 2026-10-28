extends CharacterBody3D

@export var detect_range:float = 12.0
@export var attack_range:float = 1.8
@export var chase_speed:float = 6.0
@export var damage:int = 50

@onready var health: HealthComponent = $HealthComponent
@onready var state: State = $State
@onready var visual: Node3D = $Visual
@onready var hitbox: Area3D = $Visual/Hitbox
@onready var hitbox_shape: CollisionShape3D = $Visual/Hitbox/HitboxShape
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var timer_attack: Timer = $TimerAttack

var player:CharacterBody3D
var already_hits:Array[Node3D] = []

func _ready() -> void:
	hitbox_shape.disabled = true
	add_to_group("Enemy")
	health.died.connect(_on_died)
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if player == null or state.state == state.STATE.DEAD:
		velocity.z = 0
		velocity.x = 0
		move_and_slide()
		return
	
	var to_player := player.global_position - global_position
	to_player.y = 0
	var distance := to_player.length()
	
	match state.state:
		state.STATE.IDLE:
			velocity.x = 0
			velocity.z = 0
			if distance <= detect_range:
				state.state = state.STATE.CHASE
		state.STATE.CHASE:
			if distance >= detect_range:
				state.state = state.STATE.IDLE
			var dir := to_player.normalized()
			visual.rotation.y = lerp_angle(visual.rotation.y, atan2(dir.x, dir.z), 10 * delta)
			if distance > attack_range:
				velocity.x = dir.x * chase_speed
				velocity.z = dir.z * chase_speed
			else:
				velocity.x = 0
				velocity.z = 0
				if attack_cooldown.is_stopped() and player.state.state != player.state.STATE.DEAD:
					start_attack()
		state.STATE.ATTACK:
			velocity.x = 0
			velocity.z = 0
	move_and_slide()

func _on_died():
	queue_free()

func start_attack():
	state.state = state.STATE.ATTACK
	already_hits.clear()
	hitbox_shape.disabled = false
	hitbox.monitoring = true
	timer_attack.start()

func _on_timer_attack_timeout() -> void:
	hitbox_shape.disabled = true
	hitbox.monitoring = false
	attack_cooldown.start()
	state.state = state.STATE.CHASE

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body in already_hits:
		return
	already_hits.append(body)
	
	if body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_damage(damage)

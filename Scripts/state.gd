class_name State
extends Node

enum STATE {IDLE, MOVE, JUMP, ATTACK, HURT, DEAD}
var state:STATE = STATE.IDLE

# Aturan
# - IDLE : Entity dalam Keadaan Diam Tidak Ngapain Ngapain
# - MOVE : Entity dalam Keadaan bergerak
# - ATTACK : Entity Dalam Keadaan Menyerang dan Tidak Boleh Bergerak
# - HURT : Entity Dalam Keaadaan Terkena Damage Tidak Bisa Bergerak Bila ada efek debuf seperti
#          Terkena Knockback , Enturupsi ,Stun Dan Lain nya
# - DEAD : Entity Sudah dalam keadaan MATI Tidak Boleh Bergerak Nyerang dan menerima dmg sampai 
#          nanti nya akan Di remove oleh Scripts

@export var health_component: HealthComponent

func _ready() -> void:
	health_component.died.connect(_on_die)

func _on_die():
	state = STATE.DEAD

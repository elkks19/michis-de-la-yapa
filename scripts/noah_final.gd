extends CharacterBody3D

@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 3.0
@export var KNOCKBACK_MULTIPLIER : float = 8.0
@export var ATTACK_RANGE : float = 1.0
@export var X_SENS: float = 1.0
@export var Y_SENS: float = 1.0
@export var LERP_VAL: float = 0.15
@export var HEALTH: float = 100.0

@onready var animation_player = $AnimationPlayer
@onready var neck = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D
@onready var health_bar = $"../HUD/HealthBar"
@onready var health_bar_text = $"../HUD/HealthBar/Label"

var rotation_x = 0.0
var rotation_y = 0.0
var health := 100

signal noah_hit

func _ready():
	health_bar.value = HEALTH
	health_bar_text.text = str(HEALTH).pad_decimals(0)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("noah_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("noah_camera_down"):
		neck.rotation.x -= Y_SENS * delta
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-30), deg_to_rad(60))
	if Input.is_action_pressed("noah_camera_up"):
		neck.rotation.x += Y_SENS * delta
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-30), deg_to_rad(60))
	if Input.is_action_pressed("noah_camera_left"):
		global_rotation.y += X_SENS * delta
	if Input.is_action_pressed("noah_camera_right"):
		global_rotation.y -= X_SENS * delta

	var input_dir := Input.get_vector("noah_left", "noah_right", "noah_up", "noah_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_update_animation()

func _update_animation():
	if not is_on_floor():
		_play_anim("Jump")
	elif velocity.length() > 3:
		_play_anim("Run")
	elif velocity.length() > 0.1:
		_play_anim("Walk")
	else:
		_play_anim("Idle_A")

func _play_anim(anim_name: String):
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)

func hit(dir, damage):
	emit_signal("noah_hit")
	velocity += dir * KNOCKBACK_MULTIPLIER
	HEALTH -= damage
	HEALTH = clamp(HEALTH, 0, 100)
	health_bar.value = HEALTH
	health_bar_text.text = str(HEALTH).pad_decimals(0)
	if HEALTH <= 0:
		die()

func die():
	health_bar_text.text = "MORISTE"
	print("noah ha muerto!")
	queue_free()

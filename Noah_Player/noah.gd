extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

@onready var animation_player = $Cat/AnimationPlayer
@onready var spring_arm = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D
@onready var health_bar = get_node("/root/mapa/HUD/HealthBar")

var rotation_x = 0.0
var rotation_y = 0.0
var health := 100

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if health_bar:
		health_bar.max_value = 100
		health_bar.value = health

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * MOUSE_SENSITIVITY
		rotation_x -= event.relative.y * MOUSE_SENSITIVITY
		rotation_x = clamp(rotation_x, deg_to_rad(-70), deg_to_rad(70))
		rotation.y = rotation_y
		spring_arm.rotation.x = rotation_x

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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

func take_damage(amount: int):
	health -= amount
	health = clamp(health, 0, 100)
	if health_bar:
		health_bar.value = health
	if health <= 0:
		die()

func die():
	print("¡El jugador ha muerto!")
	# Aquí podrías reproducir animación de muerte, reiniciar el nivel, etc.

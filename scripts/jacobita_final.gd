extends CharacterBody3D

@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 3.0
@export var KNOCKBACK_MULTIPLIER : float = 8.0
@export var ATTACK_RANGE : float = 1.0
@export var X_SENS: float = 0.05
@export var Y_SENS: float = 0.05
@export var LERP_VAL: float = 0.15

@onready var neck = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D
@onready var animation = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var model = $AuxScene/Skeleton3D/Cat

signal player_hit
var state_machine
var direction

func _ready():
	state_machine = anim_tree.get("parameters/playback")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * X_SENS))
			neck.rotate_x(deg_to_rad(-event.relative.y * Y_SENS))
			neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-30), deg_to_rad(60))

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Manejar movimiento
	var input_dir = Input.get_vector("jacobita_left", "jacobita_right", "jacobita_up", "jacobita_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		model.rotation.y = atan2(direction.x, direction.z) + PI
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Saltar
	if Input.is_action_just_pressed("jacobita_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()
	
	# Actualizar animaciones
	update_animations()

func update_animations():
	if not is_on_floor():
		state_machine.travel("Jump")
	elif direction.length() > 0.1:
		state_machine.travel("Run")
	else:
		state_machine.travel("Idle_A")

func hit(dir):
	emit_signal("player_hit")
	velocity += dir * KNOCKBACK_MULTIPLIER

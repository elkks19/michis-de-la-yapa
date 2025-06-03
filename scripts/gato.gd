extends CharacterBody3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var KNOCKBACK_MULTIPLIER = 8.0

@onready var neck = $SpringArm3D
@onready var camara = $SpringArm3D/Camera3D
@onready var player = $AnimationPlayer

signal player_hit

func _unhandled_input(event):




func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (neck.transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
	if direction:
		player.play('rigAction', 0.05)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		player.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func hit(dir):
	emit_signal("player_hit")
	velocity += dir * KNOCKBACK_MULTIPLIER
	

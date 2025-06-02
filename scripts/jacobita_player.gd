extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var damage_timeout := 1.0
var can_take_damage := true

@onready var player = $AnimationPlayer

func _ready() -> void:
	player.play("Idle")  # Puedes usar otra animación inicial si quieres

func _unhandled_input(_event):  # eliminamos warning usando "_event"
	var pos = get_viewport().get_mouse_position()
	look_at(Vector3(pos.x, 0, pos.y))

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimiento
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		player.play("Walk")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		player.play("Idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Movimiento con colisión
	var has_collision = move_and_slide()
	if can_take_damage and has_collision:
		for i in range(get_slide_collision_count()):
			if get_slide_collision(i).get_collider() is RigidBody3D:
				$vida.take_damage(50.0)
				can_take_damage = false
				await get_tree().create_timer(damage_timeout).timeout
				can_take_damage = true
				break

func _on_vida_no_hp_left() -> void:
	queue_free()

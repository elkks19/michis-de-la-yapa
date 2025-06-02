extends Node3D

@onready var body = $CharacterBody3D
@onready var nav_agent = $CharacterBody3D/NavigationAgent3D
@onready var player = get_tree().get_root().get_node("mapa/Noah")

const SPEED = 3.0
var damage = 10
var damage_interval = 1.0 # segundos entre cada daño
var damage_timer = 0.0

func _physics_process(delta):
	if not player or not nav_agent or not body:
		return

	# Actualiza destino del agente hacia el jugador
	nav_agent.target_position = player.global_transform.origin

	# Mueve hacia el siguiente punto
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = (next_path_pos - body.global_transform.origin).normalized()
	var velocity = direction * SPEED
	velocity.y = body.velocity.y  # mantener la gravedad

	body.velocity = velocity
	body.move_and_slide()

	# Verificar si está cerca del jugador para causar daño
	if body.global_transform.origin.distance_to(player.global_transform.origin) < 1.2:
		damage_timer -= delta
		if damage_timer <= 0:
			# Causa daño al jugador
			if player.has_method("take_damage"):
				player.take_damage(damage)
			damage_timer = damage_interval

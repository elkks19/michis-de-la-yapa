extends CharacterBody3D

var jacobita = null
var noah = null
var nearest_gato = null
var state_machine

@export var noah_path: NodePath = '/root/mapa/personajes/noah/noahViewport/noah'
@export var jacobita_path: NodePath = '/root/mapa/personajes/Jacobita/jacobitaViewport/jacobita'
@export var SPEED : float = 2.5
@export var ATTACK_RANGE : float = 0.5
@export var VIEW_RANGE: float = 10
@export var DAMAGE: float = 5.0

@onready var nav = $NavigationAgent3D
@onready var animation = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var area = $Area3D
@onready var area_collision = $Area3D/CollisionShape3D


func _ready():
	#area_collision.radius = VIEW_RANGE
	noah = get_node(noah_path)
	jacobita = get_node(jacobita_path)
	state_machine = anim_tree.get("parameters/playback")

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

func _process(delta):
	velocity = Vector3.ZERO
	
	_get_nearest_gato()
	
	match state_machine.get_current_node():
		"iddle":
			pass
			
		"walk":
			nav.set_target_position(nearest_gato.global_transform.origin)
			var next_nav_point = nav.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
			
		"attack":
			look_at(Vector3(
				nearest_gato.global_position.z,
				nearest_gato.global_position.x,
				nearest_gato.global_position.y
			), Vector3.UP)
	
	anim_tree.set('parameters/conditions/walk', _target_in_view_range())
	anim_tree.set('parameters/conditions/iddle', !_target_in_view_range())
	anim_tree.set('parameters/conditions/attack', _target_in_attack_range())
	
	move_and_slide()

func _get_nearest_gato():
	var distance_to_noah = global_position.distance_to(noah.global_position)
	var distance_to_jacobita = global_position.distance_to(jacobita.global_position)
	if distance_to_noah < distance_to_jacobita and _gato_in_range(noah):
		nearest_gato = noah
	elif distance_to_jacobita < distance_to_noah and _gato_in_range(jacobita):
		nearest_gato = jacobita

func _gato_in_range(gato):
	return area.overlaps_body(gato)

func _target_in_view_range():
	return area.overlaps_body(nearest_gato)

func _target_in_attack_range():
	if nearest_gato:
		return global_position.distance_to(nearest_gato.global_position) < ATTACK_RANGE
	else:
		return false

func _hit_finished():
	if global_position.distance_to(nearest_gato.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(nearest_gato.global_position)
		nearest_gato.hit(dir, DAMAGE)

extends CharacterBody3D

var player = null
var state_machine

@export var player_path: NodePath = '/root/mapa/gato'
@export var SPEED : float = 2.5
@export var ATTACK_RANGE : float = 1
@export var VIEW_RANGE: float = 10

@onready var nav = $NavigationAgent3D
@onready var animation = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var area = $Area3D
@onready var area_collision = $Area3D/CollisionShape3D

func _ready():
	area_collision.radius = VIEW_RANGE
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"iddle":
			pass
			
		"walk":
			nav.set_target_position(player.global_transform.origin)
			var next_nav_point = nav.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
			
		"attack":
			look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)
	
	anim_tree.set('parameters/conditions/walk', _target_in_view_range())
	anim_tree.set('parameters/conditions/iddle', !_target_in_view_range())
	
	anim_tree.set('parameters/conditions/attack', _target_in_attack_range())
	
	move_and_slide()

func _target_in_view_range():
	return area.overlaps_body(player)

func _target_in_attack_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

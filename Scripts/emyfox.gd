extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var _players_seeing: Array[Node3D] = []
var _searching = true
var _time = 0

@onready var navigation_agent = $NavigationAgent3D as NavigationAgent3D

@export var health = 4
@export var attack = 4
@export var agility = 8


func _physics_process(delta: float) -> void:
	_time += delta
	velocity = Vector3(0,0,0)
	if _players_seeing.size() > 0:
		navigation_agent.target_position = _players_seeing[0].global_position
		
		look_at(_players_seeing[0].global_position)
		
		#if !$NavigationAgent3D.is_target_reached():
			#$NavigationAgent3D.velocity = (Vector3(0,0,-1).rotated(Vector3(0,1,0),rotation.y))*agility
	#elif !$NavigationAgent3D.is_target_reached():
		#velocity = (Vector3(0,0,-1).rotated(Vector3(0,1,0),rotation.y))*agility
		#look_at($NavigationAgent3D.get_next_path_position())
		#rotation.x = 0
		#rotation.z = 0
	#else:
		#$NavigationAgent3D.target_position = position+(Vector3(0,0,10).rotated(Vector3(0,1,0),rotation.y)*agility/2)
	#else no player:
	
		#walk circle
		
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity = global_position.direction_to(next_path_position)*agility
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)



func _on_area_3d_body_entered(body: Node3D) -> void:
	_searching = false
	_players_seeing.append(body)
	
	print("entered")


func _on_area_3d_body_exited(body: Node3D) -> void:
	$NavigationAgent3D.target_position = _players_seeing[0].global_position
	_players_seeing.erase(body)
	_searching = _players_seeing.size() == 0
	print("exited")
	

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

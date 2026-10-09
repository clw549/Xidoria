class_name Player
extends CharacterBody3D
@onready var inventory: Inventory = $inventory
@onready var health_bar: ProgressBar = $Camera3D/HealthBar
@onready var area_3d: Area3D = $Area3D

var collect_list : Array[Bush] = []

const SPEED = 10

const JUMP_VELOCITY : float = 4.5

@export var sensitivity : float = .7
@export var controller_sens : float = .3
@export var max_health : int = 10
@export var current_health :float = 10

func _ready() -> void:
	health_bar.max_value = max_health

func _physics_process(delta: float) -> void:
	
	health_bar.value = current_health
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("ui_menu"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	
	handle_input()
	move_and_slide()

func handle_input():
	var look_dir := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	rotation.y -= look_dir.x /6.82* controller_sens
		
	var mouseMov := Input.get_last_mouse_velocity()
	rotation_degrees.y -= mouseMov.x/6.82*.1* sensitivity
	if Input.is_action_just_pressed("open_inventory"):
		print("inventory")
		if !inventory.visible:
			print("show")
			inventory.show()
		else:
			inventory.hide()
	if Input.is_action_just_pressed("collect"):
		for collectable in area_3d.get_overlapping_areas():
			print(collectable.name, collectable.get_parent_node_3d())
			
			if collectable.get_parent() is Bush:
				collectable.get_parent().collect_signal.emit(self)
			

func damage(damage:float):
	current_health -= damage
	if current_health <= 0:
		get_tree().reload_current_scene()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Bush:
		
		collect_list.append(body)
	print(body)
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	if collect_list.has(body):
		collect_list.erase(body)
	pass # Replace with function body.


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent_node_3d() as Bush:
		collect_list.append(area.get_parent_node_3d())
	print(area.get_parent_node_3d())



func _on_area_3d_area_exited(area: Area3D) -> void:
	if collect_list.has(area):
		collect_list.erase(area)

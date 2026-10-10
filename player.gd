class_name Player
extends CharacterBody3D
@onready var inventory: Inventory = $inventory
@onready var health_bar: ProgressBar = $Camera3D/VBoxContainer/HealthBar
@onready var area_3d: Area3D = $Area3D

var collect_list : Array[Bush] = []

const SPEED = 10

const JUMP_VELOCITY : float = 4.5

@export var sensitivity : float = .7
@export var controller_sens : float = .3
@export var max_health : int = 5*health
@onready var current_health :float = max_health
@export var agility : int = 3
@export var strength : int = 1
@export var health : int = 1
var points = 5
var experience : float = 0
var xp_to_next : float = 1000
signal send_xp(xp:float)

@onready var points_label: Label = $Camera3D/VBoxContainer/points_label
@onready var health_button: Button = $Camera3D/VBoxContainer/FoldableContainer/VBoxContainer/Stat1/health_button
@onready var health_label: Label = $Camera3D/VBoxContainer/FoldableContainer/VBoxContainer/Stat1/health_label
@onready var attack_button: Button = $Camera3D/VBoxContainer/FoldableContainer/VBoxContainer/Stat2/attack_button
@onready var attack_label: Label = $Camera3D/VBoxContainer/FoldableContainer/VBoxContainer/Stat2/attack_label
@onready var agility_button: Button = $Camera3D/VBoxContainer/FoldableContainer/VBoxContainer/Stat3/agility_button
@onready var agility_label: Label = $Camera3D/VBoxContainer/FoldableContainer/VBoxContainer/Stat3/agility_label
@onready var xp_bar: ProgressBar = $Camera3D/VBoxContainer/XpBar

func _ready() -> void:
	xp_bar.max_value = xp_to_next
	health_bar.max_value = max_health
	send_xp.connect(get_xp, 1)
	health_button.pressed.connect(upgrade_health)
	attack_button.pressed.connect(upgrade_strength)
	agility_button.pressed.connect(upgrade_agility)

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	get_xp(delta*1.2)
	
	handle_input()
	move_and_slide()

func handle_input():
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY * log(agility)
	if Input.is_action_just_pressed("ui_menu"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * (SPEED + agility)
		velocity.z = direction.z * (SPEED + agility)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED + agility)
		velocity.z = move_toward(velocity.z, 0, SPEED + agility)
		
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
	
	if Input.is_action_just_pressed("main_attack"):
		attack()
	if Input.is_action_just_pressed("secondary_attack"):
		secondary()

func damage(damage:float):
	current_health -= damage
	health_bar.value = current_health
	
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


func upgrade_health():
	if reduce_point():
		health += 1
		max_health = health*5
		health_label.text = "Health: %d" % health
		health_bar.max_value = max_health
		current_health = max_health

func upgrade_strength():
	if reduce_point():
		strength +=1
		attack_label.text = "Attack: %d" % strength


func upgrade_agility():
	if reduce_point():
		agility +=1
		agility_label.text = "Agility: %d" % agility

func reduce_point() -> bool:
	var success = false
	if points > 0:
		points -=1
		points_label.text = "Points: %d" % points
		success = true
		#hides points if there are no more and disables buy buttons
		if points == 0:
			attack_button.disabled = true
			health_button.disabled = true
			agility_button.disabled = true
			points_label.hide()
	
	return success

func get_xp(xp:float):
	experience += xp
	# level up and enables point buy buttons
	if experience >= xp_to_next:
		experience -= xp_to_next
		points += 1
		points_label.text = "Points: %d" % points
		points_label.show()
		attack_button.disabled = false
		health_button.disabled = false
		agility_button.disabled = false
		xp_bar.max_value = xp_to_next
	xp_bar.value = experience


func secondary():
	pass
	
func attack():
	var proj = load("res://Scenes/arrow.tscn") as PackedScene
	proj = proj.instantiate() as Area3D
	proj.velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	proj.rotation = rotation
	proj.global_position = global_position
	proj.xp_bubble.connect(get_xp, 1)
	get_parent().add_child(proj)
	pass

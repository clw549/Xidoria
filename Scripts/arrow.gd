extends Area3D
@onready var node_3d: Node3D = $CollisionShape3D/Node3D
var velocity : Vector3
@export var speed = 18
@export var damage = 1
@export var lifetime = 300
@export var xp_give = 2
var alivetime = 0

signal xp_bubble(xp:float)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = velocity * speed
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	alivetime += delta
	if alivetime > lifetime:
		queue_free()
	look_at(velocity)
	global_position += velocity * delta


func _on_area_entered(area: Area3D) -> void:
	print(area, area.get_parent())
	
	#area.damage(damage)
	pass # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
	print(body, body.get_parent())
	body.hit(damage)
	xp_bubble.emit(xp_give)

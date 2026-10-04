extends Node3D
@onready var progress_bar: TextureProgressBar = $SubViewport/progress_bar
@onready var replenish_timer: Timer = $ReplenishTimer

@export var resource : String = "berry"
@export var max_amount : int = 8
@export var tool : String = "none"
@export var replenish_time : int = 45
var amount = max_amount
var things: Array[Node3D]
@onready var bush : Sprite3D = $Bush
@onready var berries : Sprite3D = $Berries
@export var forage : Item
@export var forage_amount : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	replenish_timer.wait_time = replenish_time
	progress_bar.max_value = replenish_time
	progress_bar.value = replenish_time
	berries.texture = forage.texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var harvested = 0
	
	progress_bar.value = replenish_timer.time_left
	if Input.is_action_just_pressed("collect"):
		for thing in things:
			if thing.inventory :
				harvested = harvest()
				if harvested > 0:
					thing.inventory.insert_item(forage, harvested)

func harvest() -> int:
	var collected : int = 0
	if amount > 0:
		if amount-forage_amount >= 0:
			amount -= forage_amount
			collected = forage_amount
		else:
			collected = amount
			amount = 0
			
	if amount == 0:
		replenish_timer.start(replenish_time)
	return collected




func _on_area_3d_body_entered(body: Node3D) -> void:
	things.append(body)

func _on_area_3d_body_exited(body: Node3D) -> void:
	things.erase(body)


func _on_replenish_timer_timeout() -> void:
	amount = max_amount
	progress_bar.value = replenish_time

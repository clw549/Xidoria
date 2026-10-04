class_name Inventory
extends Panel

signal inventory_changed
signal collect_item(item:Item, count:int)
@onready var grid_container: GridContainer = $GridContainer
@export var num_items:int = 4
@export var columns:int = 4
var slots : Array[Slot]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collect_item.connect(insert_item)
	
	grid_container.columns = columns
	var new_slot
	for slot in num_items:
		new_slot = construct_slot()
		grid_container.add_child(new_slot)
		slots.append(new_slot)
		print(slot)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#old debugging code
	#if Input.is_action_just_pressed("open_inventory"):
		#var item = preload("res://blueberries.tres")
		#print("insert leftover",insert_item(item, 5))
func construct_slot() -> Variant:
	var slot = preload("res://inventory_slot.tscn").instantiate()
	return slot
#var data_bk
#func _notification(what: int) -> void:
	#if what == Node.NOTIFICATION_DRAG_BEGIN:
		#data_bk = get_viewport().gui_get_drag_data()
	#elif what == Node.NOTIFICATION_DRAG_END:
		#if not is_drag_successful():
			#if data_bk:
				#data_bk.show()
				#data_bk = null
func insert_item(item:Item, count:int) -> int:
	var leftover = count
	var empty_slot:Slot
	for slot:Slot in slots:
		if slot.item.item_name == "none" && empty_slot == null:
			empty_slot = slot
		# if there is an item in the inventory with the same name...
		elif slot.item.item_name == item.item_name && leftover >0:
			leftover = slot.item_count+leftover-item.stack_size
			# and there is no more leftover from inserting into the stack
			if leftover < 0:
				leftover = 0
				slot.item_count += count
			# or this maxes out the stack with possibly some left over
			else:
				slot.item_count = item.stack_size
				
			slot.refresh_item()
	#insert into an empty slot
	if empty_slot != null && leftover > 0:
		empty_slot.insert_item(item, leftover)
		leftover = 0
	return leftover

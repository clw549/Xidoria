class_name Slot
extends Panel
@onready var icon: TextureRect = $Icon
@export var item:Item = load("res://noneItem.tres")
@onready var count: Label = $Count
@export var item_count = 0

func _get_drag_data(at_position: Vector2) -> Variant:
	if icon.texture == null:
		return
		
	
	var preview = duplicate()
	var control_u = Control.new()
	control_u.add_child(preview)
	preview.position -= Vector2(25, 25)
	set_drag_preview(control_u)
	#return self for _drop_data to be able to swap item and icon 
	return self

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true
func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data.item.item_name == item.item_name:
		var stack_count = data.item_count + item_count
		
		var overflow = stack_count - item.stack_size
		print(overflow)
		if overflow > 0:
			item_count = item.stack_size
			data.item_count = overflow
		else:
			data.insert_item(load("res://noneItem.tres"))
			item_count = stack_count
	else:
		var temp = item
		var temp_count = item_count
		insert_item(data.item, data.item_count)
		data.insert_item(temp, temp_count)
	refresh_item()
	data.refresh_item()
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	insert_item(item, item_count)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func insert_item(new_item:Item, num:int=0):
	item = new_item
	item_count = num
	refresh_item()

func refresh_item():
	icon.texture = item.texture
	if item_count > 0:
		count.text = "%d"%item_count
	else: 
		count.text=""

class_name Item
extends Resource

@export var item_name: String
@export var stack_size: int
enum ItemType {TOOL, CONSUMABLE, MATERIAL}
@export var texture: Texture2D = null

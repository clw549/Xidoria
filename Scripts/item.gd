class_name Item
extends Resource

enum ItemType {TOOL, CONSUMABLE, MATERIAL}

@export var item_name: String
@export var stack_size: int
@export var texture: Texture2D = null

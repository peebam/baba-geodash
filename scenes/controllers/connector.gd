class_name Connector extends Node2D

enum Operations {
	AND,
	OR
}

@export var operation := Operations.AND

var value : bool : get = get_value

static var font := SystemFont.new()
static var scene : PackedScene = load("res://scenes/controllers/connector.tscn")
static func new_secen() -> Connector:
	var scene : Connector = scene.instantiate()
	return scene


func _draw() -> void:
	draw_line(Vector2.ZERO, -position, Color.DARK_GRAY)
	draw_circle(Vector2.ZERO, 8, Color.CORNFLOWER_BLUE, value)

	var op := "&" if operation == Operations.AND else "|"
	draw_char(font, Vector2(-4, 4), op, 12, Color.CORNFLOWER_BLUE)

# Public

func get_middle()-> Vector2:
	var positions: Array[Vector2] = [position]

	var nodes = [self]
	while not nodes.is_empty():
		var node = nodes.pop_front()
		nodes.append_array(node.get_children())
		positions.append(node.global_position)

	var sum: Vector2 = positions.reduce(func (a: Vector2, p: Vector2) -> Vector2: return a + p)
	return sum / positions.size()


func get_value()-> bool:
	var children := get_children()
	if children.is_empty():
		value = false
	else:
		match operation:
			Operations.AND:
				value = get_children().all(func(d: Node): return d.value)
			Operations.OR:
				value = get_children().any(func(d: Node): return d.value)

	queue_redraw()
	return value

class_name Detector extends ShapeCast2D

enum Targets {
	WALL,
	PIKE
}

@export var reverse := false
@export var target : Targets = Targets.WALL : set = set_target

var value := reverse :
	get = get_value,
	set = set_value

static var scene : PackedScene = load("res://scenes/controllers/detector.tscn")
static func new_secen() -> Detector:
	var scene : Detector = scene.instantiate()
	return scene


func _physics_process(delta: float) -> void:
	force_shapecast_update()
	self.value = not is_colliding() if reverse else is_colliding()


func _draw() -> void:
	draw_line(Vector2.ZERO, -position, Color.DARK_GRAY)
	var color = Color.CRIMSON if reverse else Color.FOREST_GREEN
	draw_rect(Rect2(Vector2(-8, -8), Vector2(16, 16)), color, value)
	match target:
		Targets.WALL:
			draw_rect(Rect2(Vector2(-4, -4), Vector2(8, 8)), color)
		Targets.PIKE:
			draw_line(Vector2(0, -4), Vector2(4, 4), color)
			draw_line(Vector2(0, -4), Vector2(-4, 4), color)
			draw_line(Vector2(-4, 4), Vector2(4, 4), color)

# Public

func get_value() -> bool:
	return value


func set_target(value_: Targets) -> void:
	target = value_
	match target:
		Targets.WALL:
			collision_mask = 1
		Targets.PIKE:
			collision_mask = 1 << 2


func set_value(value_: bool) -> void:
	if value == value_:
		return

	value = value_
	queue_redraw()

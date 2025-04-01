class_name Camera extends Camera2D


@export var tracked : Player
@export var x_limit : int


func _process(delta: float) -> void:
	var delta_x := tracked.global_position.x - global_position.x - x_limit
	if delta_x > 0:
		position.x += delta_x

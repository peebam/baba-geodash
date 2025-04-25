extends Node

@export var player : Player

func _physics_process(delta: float) -> void:
	player.action_jump_pressed = Input.is_action_pressed("jump")

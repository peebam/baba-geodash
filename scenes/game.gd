extends Node2D

@onready var _start_point: Node2D = $TileMapLayer/Start


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	_start()

# Privates

func _play_animation_start():
	$ForegroundLayer/AnimationPlayer.play("start")
	await $ForegroundLayer/AnimationPlayer.animation_finished


func _reset() -> void:
	$Camera.position = Vector2.ZERO
	$Player.position = _start_point.global_position


func _start() -> void:
	await _play_animation_start()
	$Player.reset()

# Signals

func _on_player_dead() -> void:
	_reset()
	_start()

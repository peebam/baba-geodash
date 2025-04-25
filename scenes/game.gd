class_name Game extends Node2D

signal score_set

@onready var _start_point: Node2D = $TileMapLayer/Start

var score := 0.0 : set = set_score

func _process(delta: float) -> void:
	score = max($Player.position.x / 100.0, 0.0)

# Public

func set_score(value: float):
	score = round(value * 10) / 10.0
	score_set.emit()


func start() -> void:
	$Player.start()
	$Camera.position = Vector2.ZERO
	$Player.position = _start_point.global_position
	_play_animation_start()


func reset() -> void:
	$Player.reset()
	$Camera.position = Vector2.ZERO
	$Player.position = _start_point.global_position

# Privates

func _play_animation_start():
	$ForegroundLayer/AnimationPlayer.play("start")
	await $ForegroundLayer/AnimationPlayer.animation_finished


func _win() -> void:
	$Player.win()

# Signals

func _on_end_zone_body_entered(body: Node2D) -> void:
	_win()

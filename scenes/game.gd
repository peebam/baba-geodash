extends Node2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	_start()

# Privates

func _reset() -> void:
	$Camera.position = Vector2.ZERO
	$Player.position = $TileMapLayer/Start.global_position


func _start() -> void:
	$ForegroundLayer/AnimationPlayer.play("start")
	await $ForegroundLayer/AnimationPlayer.animation_finished
	$Player.reset()

func _on_player_dead() -> void:
	_reset()
	_start()

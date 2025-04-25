extends Node

@export var game : Game

var _player: Player


func _ready() -> void:
	_player = game.get_node("Player")
	game.start()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("jump"):
		_player.action_jump_pressed = Input.is_action_pressed("jump")

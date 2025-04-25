extends CanvasLayer

@onready var _current_detector: Node2D = $CurrentDetector/Dislpay
@onready var _learner_controller: LearnController = get_parent()

func _ready() -> void:
	seed(1)
	_set_engine_time_scale(100)

# Private

func _set_engine_time_scale(scale: int) -> void:
	Engine.max_fps = 0
	Engine.time_scale = scale
	Engine.physics_ticks_per_second = 60 * Engine.time_scale
	Engine.max_physics_steps_per_frame = 8 * Engine.time_scale

# Signals

func _on_learner_controller_try_initialized() -> void:
	$Current/Stats/CurrentGeneration.text = "Gen #%d" %  _learner_controller.current_generation.id
	$Current/Stats/CurrentTry.text = "Try #%d" %  _learner_controller.current_try.id

	if _current_detector.get_child_count() == 2:
		var child = _current_detector.get_child(1)
		_current_detector.remove_child(child)
		child.queue_free()

	var detector: Node = _learner_controller.current_try.description.generate()
	_current_detector.add_child(detector)


func _on_learner_controller_try_terminated(won: bool) -> void:
	var ui :Node = $Current/Scroll/BestTries
	while ui.get_child_count() > 0:
		var child = ui.get_child(0)
		ui.remove_child(child)
		child.queue_free()

	var best_tries = _learner_controller.current_generation.best_tries
	for try in best_tries:
		var score : float = try.score
		var try_id: int = try.id

		var display := TryDisplay.new_secen()
		display.set_try(try_id, score)
		ui.add_child(display)

	if not won:
		_learner_controller.call_deferred("start")
	else:
		_set_engine_time_scale(1)
		_learner_controller.call_deferred("replay")

extends Node2D

@onready var _current_detector: Node2D = $Ui/CurrentDetector/Dislpay
@onready var _learner_controller: LearnController = $LearnerController

func _ready() -> void:
	set_engine_time_scale(20)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_quit()

# Public

func set_engine_time_scale(scale: float) -> void:
	Engine.max_fps = 0
	Engine.time_scale = scale
	Engine.physics_ticks_per_second = 60 * Engine.time_scale
	Engine.max_physics_steps_per_frame = 8 * Engine.time_scale

# Private

func _quit():
	get_tree().quit()


func _reset():
	$Ui/ActionsContainer/Actions/Seed/SpinBox.editable = true
	$Ui/ActionsContainer/Actions/TryPerGen/SpinBox.editable = true
	$Ui/ActionsContainer/Actions/BestTriesKept/SpinBox.editable = true
	$Ui/ActionsContainer/Actions/Start.disabled = false
	$Ui/ActionsContainer/Actions/Reset.disabled = true
	%CurrentGeneration.text = "Generation #" #%d" %  _learner_controller.current_generation.id"
	%CurrentTry.text = "Try #" #%d""
	%Distance.text = "Distance"

	_reset_detector()
	_reset_best_tries()
	_learner_controller.reset()


func _reset_detector():
	if _current_detector.get_child_count() == 2:
		var child = _current_detector.get_child(1)
		_current_detector.remove_child(child)
		child.queue_free()


func _reset_best_tries():
	while %BestTries.get_child_count() > 0:
		%BestTries.remove_child(%BestTries.get_child(0))


func _start():
	$Ui/ActionsContainer/Actions/Seed/SpinBox.editable = false
	$Ui/ActionsContainer/Actions/TryPerGen/SpinBox.editable = false
	$Ui/ActionsContainer/Actions/BestTriesKept/SpinBox.editable = false
	$Ui/ActionsContainer/Actions/Start.disabled = true
	$Ui/ActionsContainer/Actions/Reset.disabled = false
	_learner_controller.start()

# Signals

func _on_learner_controller_try_initialized() -> void:
	%CurrentGeneration.text = "Generation #%d" %  _learner_controller.current_generation.id
	%CurrentTry.text = "Try #%d" %  _learner_controller.current_try.id

	_reset_detector()
	_current_detector.add_child(
		_learner_controller.current_try.description.generate()
	)


func _on_learner_controller_try_terminated(won: bool) -> void:
	var ui :Node = %BestTries
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
		set_engine_time_scale(1)
		_learner_controller.call_deferred("replay")


func _on_start_pressed() -> void:
	_start()


func _on_reset_pressed() -> void:
	_reset()


func _on_game_score_set() -> void:
	%Distance.text = "Distance %s" % str($Game.score)


func _on_try_per_gen_spin_box_value_changed(value: float) -> void:
	_learner_controller.tries_per_generation = value


func _on_best_tries_kept_spin_box_value_changed(value: float) -> void:
	_learner_controller.best_tries_kept = value


func _on_spin_box_value_changed(value: float) -> void:
	_learner_controller.seed_value = value


func _on_time_scale_spin_box_value_changed(value: float) -> void:
	set_engine_time_scale(value)

func _on_quit_pressed() -> void:
	_quit()

class_name LearnController extends Node

signal try_initialized()
signal try_terminated(won: bool)

@export var best_tries_kept := 3
@export var game : Game
@export var seed_value : int = 1
@export var tries_per_generation := 500

var player : Player

var current_try : Dictionary = {}
var current_generation : Dictionary = {}
var previous_generation : Dictionary = {}
var current_connector : Node

func _ready() -> void:
	player = game.get_node("Player")
	player.died.connect(_on_player_died)
	player.won.connect(_on_player_won)


func _physics_process(delta: float) -> void:
	if not current_connector == null:
		player.action_jump_pressed = current_connector.get_value()

# Public

func initialize_generation():
	var generation_id: int
	if current_generation.is_empty():
		generation_id = 1
	else:
		generation_id = current_generation.id + 1
		previous_generation = current_generation

	current_generation = {
		"id": generation_id,
		"best_tries" : [] as Array[Dictionary],
		"nb_tries": 0
	}

	current_try = {}


func initialize_try():
	current_generation.nb_tries += 1

	var try_id: int = current_generation.nb_tries
	var description : Neuron.IDescription

	if previous_generation.has("id"):
		var best_tries: Array[Dictionary] = previous_generation.best_tries
		var base_description: Neuron.IDescription = best_tries[try_id % best_tries.size()].description
		description = base_description.duplicate()
		description.evolve()
	else:
		description = Neuron.ConnectorDescription.new(true)
		description.random()

	current_try = {
		"id": try_id,
		"score": 0,
		"description": description,
		"played": false
	}
	try_initialized.emit()

# Private

func _store_current_try() -> void:
	if current_try.played:
		return
	current_try.played = true

	var best_tries: Array[Dictionary] = current_generation.best_tries
	for i in best_tries.size():
		var try = best_tries[i]
		if try.score < current_try.score:
			best_tries.insert(i, current_try)

			if best_tries.size() > best_tries_kept:
				best_tries.remove_at(best_tries_kept)
			return

	if best_tries.size() < best_tries_kept:
		best_tries.append(current_try)


func replay() -> void:
	game.start()


func reset() -> void:
	current_try = {}
	current_generation = {}
	previous_generation = {}
	stop()


func start() -> void:
	if (current_try.is_empty()):
		seed(seed_value)

	if (current_try.is_empty() or
		current_try.id == tries_per_generation):
		initialize_generation()

	initialize_try()
	game.start()


func stop() -> void:
	game.reset()

# Signals

func _on_player_died():
	current_try.score = game.score
	_store_current_try()
	try_terminated.emit(false)


func _on_player_won():
	current_try.score = game.score
	_store_current_try()
	try_terminated.emit(true)


func _on_try_initialized() -> void:
	if not current_connector == null:
		player.remove_child(current_connector)
		current_connector.queue_free()

	current_connector = current_try.description.generate()
	player.add_child(current_connector)

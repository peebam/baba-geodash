class_name Player extends CharacterBody2D

signal died
signal won

enum STATES {
	IDLE,
	RUN,
	DEAD,
	JUMP,
}

const SPEED := 10.376 * 16
const JUMP := 260.0

var _state = STATES.IDLE
var _tween_rotate : Tween = null

var action_jump_pressed := false

func _physics_process(delta: float) -> void:
	if _state == STATES.DEAD or _state == STATES.IDLE:
		return

	if is_on_floor():
		$GPUParticles2D.emitting = true
		_state = STATES.RUN
		if action_jump_pressed:
			_jump()

		if velocity.x != SPEED:
			velocity.x = SPEED
	else:
		$GPUParticles2D.emitting = false

	velocity +=  get_gravity() * delta
	move_and_slide()

# Public

func start() -> void:
	reset()
	_state = STATES.RUN


func reset() -> void:
	$AnimationPlayer.play("RESET")
	_state = STATES.IDLE
	velocity = Vector2.ZERO
	$Sprite.rotation = 0
	$Sprite.position = Vector2.ZERO


func win() -> void:
	_state = STATES.IDLE
	velocity = Vector2.ZERO
	move_and_slide()
	$AnimationPlayer.play("win")
	await $AnimationPlayer.animation_finished
	won.emit()

# Private

func _die() -> void:
	if _tween_rotate != null:
		_tween_rotate.stop()

	velocity = Vector2.ZERO
	_state = STATES.DEAD
	$AnimationPlayer.play("die")


func _jump() -> void:
	if _state == STATES.RUN:
		velocity.y += -JUMP
		_state = STATES.JUMP
		_roll()


func _roll() -> void:
	_tween_rotate = get_tree().create_tween()
	_tween_rotate.tween_property($Sprite, "rotation", $Sprite.rotation + PI, 0.4)
	await _tween_rotate.finished
	_tween_rotate = null


# Signals

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		died.emit()


func _on_pike_detector_body_entered(body: Node2D) -> void:
	rotation = 0.0
	_die()

extends Node2D

@export var SPEED: float = 100.0
var motion: Vector2 = Vector2.ZERO

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if animation == null:
		push_error("AnimationPlayer node not found! Make sure node is named 'AnimationPlayer'.")
	if sprite == null:
		push_error("Sprite2D node not found! Make sure node is named 'Sprite2D'.")

func _physics_process(delta: float) -> void:
	motion = Vector2.ZERO

	# Input movement
	if Input.is_action_pressed("right"):
		motion.x += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("up"):
		motion.y -= 1

	# Attack input (click)
	if Input.is_action_just_pressed("click"):
		if animation and animation.current_animation != "attack1":
			animation.play("attack1")
		return  # stop movement while attacking

	# Movement and animation control
	if motion.length() > 0:
		motion = motion.normalized() * SPEED
		position += motion * delta

		if animation and animation.current_animation != "walk":
			animation.play("walk")

		# Flip sprite horizontally
		if sprite and abs(motion.x) > 0.01:
			sprite.flip_h = motion.x < 0
	else:
		if animation and animation.current_animation != "idle":
			animation.play("idle")

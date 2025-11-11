extends Node2D

const SPEED = 100
var motion = Vector2()
var animation: AnimationPlayer
var sprite: Sprite2D  # Explicit type helps with debugging

func _ready() -> void:
	# Make sure these nodes exist in your scene tree
	animation = $AnimationSoldier
	sprite = $Soldier

	if sprite == null:
		push_error("❌ Sprite2D node not found! Make sure the node is named 'Soldier'.")
	if animation == null:
		push_error("❌ AnimationPlayer node not found! Make sure it's named 'AnimationPlayer'.")

func _physics_process(delta: float) -> void:
	motion = Vector2()

	# Movement input
	if Input.is_action_pressed("right"):
		motion.x += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("up"):
		motion.y -= 1

	if motion.length() > 0:
		motion = motion.normalized() * SPEED
		animation.play("walk")

		# Flip horizontally (check if sprite exists)
		if sprite:
			sprite.flip_h = motion.x < 0
	else:
		animation.play("idle")

	position += motion * delta

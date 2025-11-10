extends Node2D

const SPEED = 300
var motion = Vector2()
var animation
var sprite

func _ready() -> void:
	animation = $AnimationPlayer
	sprite = $Soldier   # Make sure your Sprite2D node is named “Soldier”

func _physics_process(delta):
	# Reset motion every frame
	motion = Vector2()

	# Movement input
	if Input.is_action_pressed("ui_right"):
		motion.x += 1
	if Input.is_action_pressed("ui_left"):
		motion.x -= 1
	if Input.is_action_pressed("ui_down"):
		motion.y += 1
	if Input.is_action_pressed("ui_up"):
		motion.y -= 1

	# Normalize so diagonal movement isn't faster
	if motion.length() > 0:
		motion = motion.normalized() * SPEED
		animation.play("walk")

		# Flip horizontally
		if motion.x > 0:
			sprite.flip_h = false
		elif motion.x < 0:
			sprite.flip_h = true
	else:
		animation.play("idle")

	# Move character
	position += motion * delta

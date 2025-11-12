extends Node2D

@export var SPEED: float = 100.0
var motion := Vector2.ZERO

# Exposed NodePaths (set in the Inspector)
@export var gfx_path: NodePath
@export var anim_path: NodePath

# Auto-assigned references (loaded in _ready)
var gfx: Node2D
var animation: AnimationPlayer

func _ready() -> void:
	# Load the nodes if assigned
	if gfx_path != NodePath():
		gfx = get_node(gfx_path) as Node2D
	else:
		push_warning("⚠️ 'gfx_path' not assigned in Inspector — Sprite2D will not flip.")

	if anim_path != NodePath():
		animation = get_node(anim_path) as AnimationPlayer
	else:
		push_warning("⚠️ 'anim_path' not assigned in Inspector — animations will not play.")

func _physics_process(delta: float) -> void:
	motion = Vector2.ZERO

	# Movement input
	if Input.is_action_pressed("right"): motion.x += 1
	if Input.is_action_pressed("left"):  motion.x -= 1
	if Input.is_action_pressed("down"):  motion.y += 1
	if Input.is_action_pressed("up"):    motion.y -= 1

	# Attack input
	if Input.is_action_just_pressed("click"):
		if animation and animation.current_animation != "attack1":
			animation.play("attack1")
		return  # skip movement while attacking

	# Movement and animation logic
	if motion != Vector2.ZERO:
		motion = motion.normalized() * SPEED
		position += motion * delta

		# Flip sprite depending on movement direction
		if gfx and abs(motion.x) > 0.01:
			var sx: float = abs(gfx.scale.x)
			gfx.scale.x = -sx if motion.x < 0 else sx

		if animation and animation.current_animation not in ["walk", "attack1"]:
			animation.play("walk")
	else:
		if animation and animation.current_animation not in ["idle", "attack1"]:
			animation.play("idle")

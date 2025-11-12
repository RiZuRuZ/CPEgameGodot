extends Node2D

@export var SPEED: float = 100.0
var motion := Vector2.ZERO

@export var gfx_path: NodePath
@export var anim_path: NodePath

@onready var gfx: Node2D = $"CharacterBody2D/Soldier"        # your Sprite2D
@onready var animation: AnimationPlayer = $"CharacterBody2D/AnimationPlayer"  # sibling of CharacterBody2D

func _physics_process(_delta: float) -> void:
	motion = Vector2.ZERO
	if Input.is_action_pressed("right"): motion.x += 1
	if Input.is_action_pressed("left"):  motion.x -= 1
	if Input.is_action_pressed("down"):  motion.y += 1
	if Input.is_action_pressed("up"):    motion.y -= 1

	if Input.is_action_just_pressed("click"):
		if animation and animation.current_animation != "attack1":
			animation.play("attack1")
			
		return

	if motion != Vector2.ZERO:
		motion = motion.normalized() * SPEED
		position += motion * _delta

		if gfx and abs(motion.x) > 0.01:
			var sx: float = abs(gfx.scale.x)
			gfx.scale.x = -sx if motion.x < 0 else sx

		if animation and animation.current_animation not in ["walk", "attack1"]:
			animation.play("walk")
	else:
		if animation and animation.current_animation not in ["idle", "attack1"]:
			animation.play("idle")

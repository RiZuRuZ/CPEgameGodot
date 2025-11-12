# PlayerController2D.gd
extends Node2D
class_name PlayerController2D

@export var speed: float = 100.0
@export var input_right: StringName = "right"
@export var input_left:  StringName = "left"
@export var input_up:    StringName = "up"
@export var input_down:  StringName = "down"
@export var input_attack: StringName = "click"

# Scene bindings (set these in the Inspector)
@export var gfx_path: NodePath            # Sprite2D / AnimatedSprite2D (the visible node)
@export var anim_path: NodePath           # AnimationPlayer

# Animation clip names
@export var anim_idle: StringName = "idle"
@export var anim_walk: StringName = "walk"
@export var anim_attack_side: StringName = "attack1"

var _motion: Vector2 = Vector2.ZERO
var _attack_lock: bool = false

@onready var gfx: Node2D = get_node_or_null(gfx_path) as Node2D
@onready var animation: AnimationPlayer = get_node_or_null(anim_path) as AnimationPlayer

func _ready() -> void:
	# Fallbacks in case you forget to wire NodePaths (mirrors your hard-coded style)
	if gfx == null:
		gfx = get_node_or_null("CharacterBody2D/Soldier") as Node2D
	if animation == null:
		animation = get_node_or_null("CharacterBody2D/AnimationPlayer") as AnimationPlayer

func _physics_process(delta: float) -> void:
	_motion = Vector2.ZERO

	if not _attack_lock:
		if Input.is_action_pressed(input_right): _motion.x += 1.0
		if Input.is_action_pressed(input_left):  _motion.x -= 1.0
		if Input.is_action_pressed(input_down):  _motion.y += 1.0
		if Input.is_action_pressed(input_up):    _motion.y -= 1.0

		if Input.is_action_just_pressed(input_attack):
			_start_attack()
			return

	if _motion != Vector2.ZERO and not _attack_lock:
		_motion = _motion.normalized() * speed
		position += _motion * delta

		if gfx and abs(_motion.x) > 0.01:
			var sx: float = abs(gfx.scale.x)
			gfx.scale.x = -sx if _motion.x < 0.0 else sx

		_play(anim_walk)
	else:
		_play(anim_idle)

func _start_attack() -> void:
	if animation and animation.current_animation != anim_attack_side:
		_attack_lock = true
		animation.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)
		animation.play(anim_attack_side)

func _on_anim_finished(name: StringName) -> void:
	if name == anim_attack_side:
		_attack_lock = false

func _play(name: StringName) -> void:
	if animation and animation.current_animation != name and not _attack_lock:
		animation.play(name)

func _get_configuration_warnings() -> PackedStringArray:
	var w := PackedStringArray()
	if gfx == null and gfx_path.is_empty():
		w.append("Assign 'gfx_path' to your visible Sprite2D/AnimatedSprite2D (or keep default fallback path).")
	if animation == null and anim_path.is_empty():
		w.append("Assign 'anim_path' to your AnimationPlayer (or keep default fallback path).")
	return w

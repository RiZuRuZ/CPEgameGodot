extends Node2D

@export var SPEED: float = 100.0
var motion := Vector2.ZERO

# Exposed NodePaths (set in the Inspector)
@export var gfx_path: NodePath
@export var anim_path: NodePath
@export var hitbox1_path: NodePath
@export var hitbox2_path: NodePath

# Auto-assigned references
var gfx: Node2D
var animation: AnimationPlayer
var hitbox1: Area2D
var hitbox2: Area2D
var hitshape1: CollisionShape2D
var hitshape2: CollisionShape2D

# Movement control
var can_move := true
var is_attacking := false

func _ready() -> void:
	if gfx_path != NodePath():
		gfx = get_node(gfx_path) as Node2D
	else:
		push_warning("⚠️ 'gfx_path' not assigned.")

	if anim_path != NodePath():
		animation = get_node(anim_path) as AnimationPlayer
	else:
		push_warning("⚠️ 'anim_path' not assigned.")

	if animation:
		animation.animation_finished.connect(_on_anim_finished)

	# --- Hitboxes ---
	if hitbox1_path != NodePath():
		hitbox1 = get_node(hitbox1_path) as Area2D
		hitshape1 = hitbox1.get_node("CollisionShape2D") as CollisionShape2D
	else:
		push_warning("⚠️ 'hitbox1_path' not assigned.")

	if hitbox2_path != NodePath():
		hitbox2 = get_node(hitbox2_path) as Area2D
		hitshape2 = hitbox2.get_node("CollisionShape2D") as CollisionShape2D
	else:
		push_warning("⚠️ 'hitbox2_path' not assigned.")

	# Disable both hitboxes at start
	_disable_all_hitboxes()


func _physics_process(delta: float) -> void:
	motion = Vector2.ZERO

	# === BLOCK MOVEMENT ONLY IF can_move == false ===
	if not can_move:
		return

	# Movement input
	if Input.is_action_pressed("right"): motion.x += 1
	if Input.is_action_pressed("left"):  motion.x -= 1
	if Input.is_action_pressed("down"):  motion.y += 1
	if Input.is_action_pressed("up"):    motion.y -= 1

# Attack input (left click - can still move)
	if Input.is_action_just_pressed("m1"):
		_start_attack("attack1", false, 1)  # use Hitbox1

	# Attack input (Q - lock movement)
	if Input.is_action_just_pressed("q"):
		_start_attack("attack2", true, 2)   # use Hitbox2
		return   # stop movement during attack2

	# Movement + walk animation
	if motion != Vector2.ZERO:
		motion = motion.normalized() * SPEED
		position += motion * delta

		if gfx and abs(motion.x) > 0.01:
			var sx = abs(gfx.scale.x)
			gfx.scale.x = -sx if motion.x < 0 else sx

		if animation and animation.current_animation not in ["walk", "attack1", "attack2"]:
			animation.play("walk")
	else:
		if animation and animation.current_animation not in ["idle", "attack1", "attack2"]:
			animation.play("idle")


func _disable_all_hitboxes() -> void:
	if hitbox1:
		hitbox1.monitoring = false
		hitbox1.monitorable = false
	if hitshape1:
		hitshape1.disabled = true

	if hitbox2:
		hitbox2.monitoring = false
		hitbox2.monitorable = false
	if hitshape2:
		hitshape2.disabled = true



func _enable_hitbox(which: int) -> void:
	# Turn everything off first
	_disable_all_hitboxes()

	if which == 1 and hitbox1:
		hitbox1.monitoring = true
		hitbox1.monitorable = true
		if hitshape1:
			hitshape1.disabled = false

	elif which == 2 and hitbox2:
		hitbox2.monitoring = true
		hitbox2.monitorable = true
		if hitshape2:
			hitshape2.disabled = false

# ======================================================
# ATTACK HANDLING
# ======================================================
func _start_attack(anim_name: String, lock_movement: bool, which_hitbox: int) -> void:
	is_attacking = true
	can_move = not lock_movement

	_enable_hitbox(which_hitbox)   # <--- activate the correct hitbox

	if animation:
		animation.play(anim_name)


func _on_anim_finished(anim_name: String) -> void:
	if anim_name in ["attack1", "attack2"]:
		is_attacking = false
		can_move = true
		_disable_all_hitboxes()
		

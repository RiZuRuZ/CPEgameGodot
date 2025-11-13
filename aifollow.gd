extends Node2D

@export var SPEED: float = 50.0
@export var STOP_RADIUS: float = 18.0
@export var ATTACK_RADIUS: float = 22.0
@export var ATTACK_DELAY: float = 0.5

@onready var gfx: Node2D = $"CharacterBody2D/Slime"
@onready var animation: AnimationPlayer = $"CharacterBody2D/AnimationPlayer"
@onready var area: Area2D = $Area2D

var player: Node2D = null
var last_dir := Vector2.RIGHT
var can_attack := true
var death := false

func _ready() -> void:
	await get_tree().process_frame
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as Node2D
	else:
		push_error("Slime: no node in group 'player'")

	# --- connect signals ---
	if area:
		print("Slime: Area2D found ->", area.name)
		area.area_entered.connect(_on_area_2d_area_entered)
	else:
		push_error("Slime: Area2D node missing")

	if animation:
		animation.animation_finished.connect(_on_animation_player_animation_finished)
	else:
		push_error("Slime: AnimationPlayer missing")

func _physics_process(delta: float) -> void:
	if death:
		return

	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		else:
			return

	var to_player := player.global_position - global_position
	var dist := to_player.length()
	var axis_side: bool = abs(to_player.x) >= abs(to_player.y)

	# --- Facing / flip ---
	if abs(to_player.x) > 0.01 and gfx:
		var sx: float = abs(gfx.scale.x)
		gfx.scale.x = -sx if to_player.x < 0 else sx

	# --- Movement ---
	if dist > STOP_RADIUS and can_attack:
		var step := to_player.normalized() * SPEED * delta
		if step.length() > dist:
			step = to_player
		position += step
		if step != Vector2.ZERO:
			last_dir = step.normalized()

	# --- Animation state ---
	if dist <= ATTACK_RADIUS:
		if can_attack:
			can_attack = false
			_start_attack(axis_side)
	else:
		if can_attack:
			if dist > STOP_RADIUS:
				play_anim("walk")
			else:
				play_anim("idle")

# --- Attack handler ---
func _start_attack(axis_side: bool) -> void:
	play_anim("idle")  # brief pause
	await get_tree().create_timer(ATTACK_DELAY).timeout
	if player == null || death:
		can_attack = true
		return

	var to_player := player.global_position - global_position
	if to_player.length() <= ATTACK_RADIUS:
		if axis_side:
			play_anim("attack1")
		else:
			play_anim("attack2")

	if animation and is_inside_tree():
		await animation.animation_finished

	can_attack = true

# --- Collision handler ---
func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Slime: area_entered ->", area.name, "groups:", area.get_groups())
	if area.is_in_group("Hitbox") and not death:
		death = true
		play_anim("death")

# --- Animation finished handler ---
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()

# --- Animation control ---
func play_anim(name: String) -> void:
	if animation and animation.current_animation != name:
		animation.play(name)

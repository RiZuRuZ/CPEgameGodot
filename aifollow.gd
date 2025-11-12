# slime_follow.gd (attach to Slime's Node2D)
extends Node2D

@export var SPEED: float = 50.0
@export var STOP_RADIUS: float = 18.0         # distance where slime stops drifting
@export var ATTACK_RADIUS: float = 22.0       # start attacks when within this distance

# Hard-coded paths (match your scene)
@onready var gfx: Node2D = $"CharacterBody2D/Slime"          # Sprite2D/AnimatedSprite2D
@onready var animation: AnimationPlayer = $"CharacterBody2D/AnimationPlayer"  # AnimationPlayer

var player: Node2D = null
var last_dir := Vector2.RIGHT  # remember last movement to keep facing when standing

func _ready() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as Node2D
	else:
		push_error("Slime: no node in group 'player'. Add your player root to the 'player' group.")

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()
	var axis_side: bool = abs(to_player.x) >= abs(to_player.y)  # true = side, false = vertical

	# ---------- Facing / flip ----------
	if abs(to_player.x) > 0.01 and gfx:
		var sx: float = abs(gfx.scale.x)
		gfx.scale.x = -sx if to_player.x < 0 else sx

	# ---------- Movement ----------
	if dist > STOP_RADIUS:
		# Move toward player (same style as your player script: move the Node2D)
		var step := to_player.normalized() * SPEED * delta
		if step.length() > dist:
			step = to_player
		position += step
		if step != Vector2.ZERO:
			last_dir = step.normalized()
	else:
		# Keep position; last_dir remains for facing
		pass

	# ---------- Animation state ----------
	if dist <= ATTACK_RADIUS:
		# Choose attack by orientation
		if axis_side:
			play_anim("attack1")      # player is left/right → side attack
		else:
			play_anim("attack2")      # player is up/down → vertical attack
	else:
		# Not attacking → walk/idle
		if dist > STOP_RADIUS:
			play_anim("walk")
		else:
			play_anim("idle")

# Plays only if different from current to avoid restarting every frame
func play_anim(name: String) -> void:
	if animation and animation.current_animation != name:
		animation.play(name)

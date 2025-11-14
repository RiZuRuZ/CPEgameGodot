extends CharacterBody2D

@export var SPEED: float = 50.0
@export var STOP_RADIUS: float = 18.0
@export var ATTACK_RADIUS: float = 23.0
@export var ATTACK_DELAY: float = 0.5

# --- Exposed NodePaths (set these in the Inspector) ---
@export var gfx_path: NodePath
@export var anim_path: NodePath
@export var area_path: NodePath

# --- Auto-assigned references ---
var gfx: Node2D
var animation: AnimationPlayer
var area: Area2D

var health := 100
var player: Node2D = null
var last_dir := Vector2.RIGHT
var can_attack := true
var death := false


func _ready() -> void:
	# ปิดคอลลิชันของ hitbox (ถ้าต้องการ)
	# *** ถ้าปิดบรรทัดนี้ ศัตรูจะโดนดาเมจไม่ได้ ***
	$CharacterBody2D/Slime/Area2D/CollisionShape2D.disabled = true

	# Resolve exported paths
	if gfx_path != NodePath():
		gfx = get_node(gfx_path) as Node2D
	else:
		push_warning("Slime: 'gfx_path' not assigned.")

	if anim_path != NodePath():
		animation = get_node(anim_path) as AnimationPlayer
	else:
		push_warning("Slime: 'anim_path' not assigned.")

	if area_path != NodePath():
		area = get_node(area_path) as Area2D
	else:
		push_warning("Slime: 'area_path' not assigned.")

	# Connect signals AFTER nodes are resolved
	if area:
		print("Slime: Area2D found ->", area.name)
		area.area_entered.connect(_on_area_2d_area_entered)
	else:
		push_error("Slime: Area2D node missing")

	if animation:
		animation.animation_finished.connect(_on_animation_player_animation_finished)
	else:
		push_error("Slime: AnimationPlayer missing")

	# Find player (wait one frame so player can spawn from main scene)
	await get_tree().process_frame
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as Node2D
	else:
		push_error("Slime: no node in group 'player'")

	$Bar.max_value = health


func _physics_process(delta: float) -> void:
	$Bar.value = health

	if death:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			return

	var to_player := player.global_position - global_position
	var dist := to_player.length()

	# ใช้ float แบบชัดเจน + boolean เปรียบเทียบแนวนอน/แนวตั้ง
	var axis_side: bool = (absf(to_player.x) - 10.0) >= absf(to_player.y)

	# --- Facing / flip ---
	if absf(to_player.x) > 0.01 and gfx:
		var sx: float = absf(gfx.scale.x)
		gfx.scale.x = -sx if to_player.x < 0.0 else sx

	# --- Movement (ใช้ velocity + move_and_slide) ---
	if dist > STOP_RADIUS and can_attack:
		velocity = to_player.normalized() * SPEED
		if velocity != Vector2.ZERO:
			last_dir = velocity.normalized()
	else:
		velocity = Vector2.ZERO

	move_and_slide()

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
	if player == null or death:
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
func _on_area_2d_area_entered(hit: Area2D) -> void:
	if death:
		return

	print("Slime: area_entered ->", hit.name, "groups:", hit.get_groups())

	if hit.is_in_group("Hitbox1"):
		health -= 20
	elif hit.is_in_group("Hitbox2"):
		health -= 40

	if health <= 0 and not death:
		death = true
		can_attack = false
		play_anim("death")


# --- Animation finished handler ---
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()


# --- Animation control ---
func play_anim(name: String) -> void:
	if animation and animation.current_animation != name:
		animation.play(name)

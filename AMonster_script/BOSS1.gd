extends CharacterBody2D

# ===============================
# BOSS SETUP
# ===============================
@export var SPEED: float = 35.0          # ช้ากว่าปกติ
@export var STOP_RADIUS: float = 22.0
@export var ATTACK_RADIUS: float = 30.0
@export var ATTACK_DELAY: float = 0.5
@export var DETECT_RADIUS: float = 260.0
@export var IDLE_CHANGE_TIME: float = 1.5

# ===============================
# STATS (BOSS)
# ===============================
@export var health: int = 300             # ⭐ เลือดเยอะ
@export var atk1dmg: int = 40             # ⭐ ตีแรง
@export var atk2dmg: int = 40
@export var bodydmg: int = 25

var PreHealth := 0
var damaged := false
var enraged := false     # ⭐ Phase 2

# ===============================
# NODE PATHS
# ===============================
@export var gfx_path: NodePath
@export var anim_path: NodePath
@export var area_path: NodePath

var gfx: Node2D
var animation: AnimationPlayer
var area: Area2D

# ===============================
# STATE
# ===============================
var player: Node2D
var last_dir := Vector2.RIGHT

var death := false
var is_hurt := false
var can_move := true
var can_attack := true

enum State { IDLE, CHASE, ATTACK }
var state := State.IDLE
var idle_dir := Vector2.ZERO
var idle_timer := 0.0

# ===============================
# SUMMON SYSTEM
# ===============================
@export var summon_scenes: Array[PackedScene]   # ใส่ Slime / Skeleton / Orc
@export var summon_cooldown: float = 15.0       # ⭐ แก้เป็น 15 วินาที
@export var max_minions: int = 5                # (ค่านี้ไม่มีผลแล้วเพราะเสกไม่อั้น)
@export var summon_radius: float = 60.0

var summon_timer := 0.0

# ===============================
# READY
# ===============================
func _ready() -> void:
	randomize()
	add_to_group("EnemyBody")

	scale = Vector2(1.8, 1.8)   # ⭐ ตัวใหญ่ขึ้น

	PreHealth = health
	
	# Check node exist before disable
	if has_node("CharacterBody2D/Slime/atk1/CollisionShape2D"):
		$CharacterBody2D/Slime/atk1/CollisionShape2D.set_deferred("disabled", true)

	if gfx_path != NodePath():
		gfx = get_node(gfx_path)
	if anim_path != NodePath():
		animation = get_node(anim_path)
	if area_path != NodePath():
		area = get_node(area_path)

	await get_tree().process_frame
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		
	$Bar.max_value = health
	_set_idle_dir()
	play_anim("idle")

# ===============================
# MAIN LOOP
# ===============================
func _physics_process(delta: float) -> void:
	$Bar.value = health
	damaged = false

	# ---------- DEATH ----------
	if health <= 0 and not death:
		death = true
		can_move = false
		can_attack = false
		is_hurt = false
		summon_timer = 9999
		velocity = Vector2.ZERO
		play_anim("death")
		return

	# ---------- DAMAGE ----------
	if PreHealth != health:
		damaged = true
		show_damage(PreHealth - health)
		PreHealth = health

		if health > 0:
			is_hurt = true
			can_move = false
			can_attack = false
			play_anim("hurt")

	# ---------- RAGE PHASE ----------
	if not enraged and health <= 250:
		_enter_rage()

	# ⭐ FIX: ล็อคสีแดงไว้ตลอดเวลาที่ Enraged
	if enraged and not death:
		modulate = Color(1.5, 0.5, 0.5)

	if is_hurt:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		else:
			_do_idle(delta)
			move_and_slide()
			return

	var to_player := player.global_position - global_position
	var dist := to_player.length()

	# flip
	if absf(to_player.x) > 0.01 and gfx:
		var sx: float = absf(gfx.scale.x)
		gfx.scale.x = -sx if to_player.x < 0.0 else sx

	# state
	if dist > DETECT_RADIUS:
		state = State.IDLE
	elif dist > ATTACK_RADIUS:
		state = State.CHASE
	else:
		state = State.ATTACK

	match state:
		State.IDLE:
			_do_idle(delta)
		State.CHASE:
			_do_chase(to_player)
		State.ATTACK:
			_do_attack(to_player)
	
	# ---------- SUMMON ----------
	if enraged and not death:
		summon_timer -= delta
		if summon_timer <= 0:
			_try_summon()
			summon_timer = summon_cooldown
	move_and_slide()

# ===============================
# BEHAVIOURS
# ===============================
func _do_idle(delta: float) -> void:
	idle_timer -= delta
	if idle_timer <= 0:
		_set_idle_dir()

	velocity = idle_dir * SPEED * 0.4
	play_anim("idle" if idle_dir == Vector2.ZERO else "walk")

func _set_idle_dir() -> void:
	idle_timer = IDLE_CHANGE_TIME + randf()
	if randf() < 0.3:
		idle_dir = Vector2.ZERO
	else:
		var a := randf() * TAU
		idle_dir = Vector2(cos(a), sin(a)).normalized()

func _do_chase(to_player: Vector2) -> void:
	if not can_attack:
		velocity = Vector2.ZERO
		return

	velocity = to_player.normalized() * SPEED
	play_anim("walk")

func _do_attack(to_player: Vector2) -> void:
	if not can_attack:
		return

	can_attack = false
	can_move = false
	velocity = Vector2.ZERO

	var axis_side := absf(to_player.x) > absf(to_player.y)
	_start_attack(axis_side)

# ===============================
# ATTACK
# ===============================
func _start_attack(axis_side: bool) -> void:
	attack_coroutine(axis_side)

func attack_coroutine(axis_side: bool) -> void:
	await get_tree().create_timer(ATTACK_DELAY).timeout

	if death or is_hurt:
		can_attack = true
		can_move = true
		return

	if axis_side:
		play_anim("attack1")
	else:
		play_anim("attack2")

	if animation:
		await animation.animation_finished

	can_attack = true
	can_move = true

# ===============================
# RAGE MODE
# ===============================
func _enter_rage():
	enraged = true
	SPEED *= 2.0
	atk1dmg += 10
	atk2dmg += 10
	bodydmg += 15
	summon_timer = 1.0
	play_anim("rage")
	
	modulate = Color(1.5, 0.5, 0.5)
	print("BOSS SLIME ENRAGED!")


# ===============================
# ANIMATION EVENTS
# ===============================
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		drop_item()
		queue_free()
	elif anim_name == "hurt":
		is_hurt = false
		can_move = true
		can_attack = true

func play_anim(name: String) -> void:
	if animation and animation.current_animation != name:
		animation.play(name)

# ===============================
# DAMAGE PLAYER
# ===============================
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and not area.get_parent().is_invincible:
		var player := area.get_parent()
		player.health -= bodydmg
		show_damage_to_player(bodydmg, player)

func _on_area_2d_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and not area.get_parent().is_invincible:
		var player := area.get_parent()
		player.health -= atk1dmg
		show_damage_to_player(atk1dmg, player)


func _on_atk_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and not area.get_parent().is_invincible:
		var player := area.get_parent()
		player.health -= atk2dmg
		show_damage_to_player(atk2dmg, player)

# ===============================
# DROP
# ===============================
func drop_item():
	var scene := preload("res://Pickup/pickups.tscn")
	var drop := scene.instantiate()
	drop.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", drop)

# ===============================
# DAMAGE POPUP
# ===============================
func show_damage(amount: int):
	var popup := preload("res://Animation5+3/DamagePopUp.tscn").instantiate()
	get_tree().current_scene.add_child(popup)
	popup.global_position = global_position + Vector2(10, -10)
	popup.set_text(str(amount), Color.WHITE if damaged else Color.RED)

func show_damage_to_player(amount: int, target: Node2D):
	var popup := preload("res://Animation5+3/DamagePopUp.tscn").instantiate()
	get_tree().current_scene.add_child(popup)

	popup.global_position = target.global_position + Vector2(0, -10)
	popup.set_text(str(amount), Color.RED)

func _try_summon():
	# ⭐ Unlimited Summon & Batch Logic
	if summon_scenes.is_empty():
		return

	play_anim("attack1") 

	# วนลูปเสก 2 ตัว
	for i in range(2):
		var scene: PackedScene = summon_scenes.pick_random()
		var minion = scene.instantiate()

		var angle = randf() * TAU
		var offset = Vector2(cos(angle), sin(angle)) * (summon_radius + randf() * 20.0)
		minion.global_position = global_position + offset

		get_tree().current_scene.call_deferred("add_child", minion)

	print("BOSS SUMMONED 2 MINIONS (UNLIMITED)")

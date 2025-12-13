extends CharacterBody2D

# ===============================
# BOSS SETTINGS (BOSS 4)
# ===============================
@export var SPEED: float = 55.0           # ความเร็วปานกลาง
@export var STOP_RADIUS: float = 36.0
@export var ATTACK_RADIUS: float = 36.0   # เพิ่มระยะตีหน่อย
@export var ATTACK_DELAY: float = 0.3
@export var DETECT_RADIUS: float = 260.0
@export var IDLE_CHANGE_TIME: float = 1.5

# ===============================
# STATS (BOSS)
# ===============================
@export var health: int = 800             # ⭐ เลือด 650
@export var atk1dmg : int = 30
@export var atk2dmg : int = 45            # ท่า Finisher แรง
@export var atk3dmg : int = 30            # ท่าโจมตีสวน (Upper/Special)
@export var bodydmg : int = 20

var PreHealth = 0
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
# STATE & SYSTEM
# ===============================
var player: Node2D = null
var last_dir := Vector2.RIGHT

var death := false
var is_hurt := false
var can_move := true
var can_attack := true

enum State { IDLE, CHASE, ATTACK }
var state: int = State.IDLE
var idle_dir := Vector2.ZERO
var idle_timer := 0.0
var SOA := 0  # Sequence of Attack

# ===============================
# SUMMON SYSTEM
# ===============================
@export var summon_scenes: Array[PackedScene]
@export var summon_cooldown: float = 15.0
@export var max_minions: int = 5
@export var summon_radius: float = 60.0

var summon_timer := 0.0

# ===============================
# MAIN CODE
# ===============================
func _ready() -> void:
	randomize()
	add_to_group("EnemyBody")

	scale = Vector2(1.6, 1.6) # ⭐ ขยายขนาด (เล็กกว่า Orc/Werebear นิดหน่อย)
	PreHealth = health
	
	_disable_collision()

	if gfx_path != NodePath():
		gfx = get_node(gfx_path) as Node2D
	if anim_path != NodePath():
		animation = get_node(anim_path) as AnimationPlayer
	if area_path != NodePath():
		area = get_node(area_path) as Area2D
	
	await get_tree().process_frame
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as Node2D

	$Bar.max_value = health
	$Bar.size = Vector2(20.375, 2.0)
	$Bar.position = Vector2(-10.0, -12.0)
	
	_set_idle_dir()
	play_anim("idle")

func _physics_process(delta: float) -> void:
	$Bar.value = health
	damaged = false
	
	# --- DEATH CHECK ---
	if health <= 0 and not death:
		death = true
		can_attack = false
		can_move = false
		is_hurt = false
		summon_timer = 9999
		if $CollisionShape2D: $CollisionShape2D.set_deferred("disabled", true)
		play_anim("death")
		return

	# --- DAMAGE CHECK ---
	if PreHealth != health:
		damaged = true
		show_damage(PreHealth - health)
		PreHealth = health

		# Boss อาจจะไม่ต้องชะงัก (Hurt) บ่อยๆ ถ้าอยากให้โหด
		if not death:
			is_hurt = true
			can_move = false
			can_attack = false
			if animation:
				animation.play("hurt")

	# --- RAGE PHASE ---
	if not enraged and health <= 300: # เลือดต่ำกว่า 300
		_enter_rage()

	# Color Lock
	if enraged and not death:
		modulate = Color(1.5, 0.5, 0.5)

	# --- MOVEMENT STOPPERS ---
	if death:
		return

	if is_hurt or not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0] as Node2D
		else:
			_do_idle(delta)
			move_and_slide()
			return

	var to_player := player.global_position - global_position
	var dist := to_player.length()

	# Flip
	if absf(to_player.x) > 0.01 and gfx:
		var sx: float = absf(gfx.scale.x)
		gfx.scale.x = -sx if to_player.x < 0.0 else sx

	# --- STATE MACHINE ---
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
	
	# --- SUMMON LOGIC ---
	if enraged and not death:
		summon_timer -= delta
		if summon_timer <= 0:
			_try_summon()
			summon_timer = summon_cooldown

	move_and_slide()

# ===============================
# BEHAVIORS
# ===============================
func _do_idle(delta: float) -> void:
	idle_timer -= delta
	if idle_timer <= 0.0:
		_set_idle_dir()

	velocity = idle_dir * SPEED * 0.4
	if idle_dir == Vector2.ZERO:
		play_anim("idle")
	else:
		play_anim("walk")

func _set_idle_dir() -> void:
	idle_timer = IDLE_CHANGE_TIME + randf() * 0.8
	if randf() < 0.3:
		idle_dir = Vector2.ZERO
	else:
		var angle := randf() * TAU
		idle_dir = Vector2(cos(angle), sin(angle)).normalized()

func _do_chase(to_player: Vector2) -> void:
	if not can_attack:
		velocity = Vector2.ZERO
		play_anim("idle")
		return

	var dir := to_player.normalized()
	velocity = dir * SPEED
	last_dir = dir
	play_anim("walk")

func _do_attack(to_player: Vector2) -> void:
	velocity = Vector2.ZERO
	if not can_attack:
		return

	can_attack = false
	can_move = false
	play_anim("idle")
	
	var axis_side: bool = (absf(to_player.x) - 10.0) >= absf(to_player.y)
	_start_attack(axis_side)

# ===============================
# ATTACK LOGIC (Based on Provided Code)
# ===============================
func _start_attack(axis_side: bool) -> void:
	attack_coroutine(axis_side)

func attack_coroutine(axis_side: bool) -> void:
	await get_tree().create_timer(ATTACK_DELAY).timeout

	if death or is_hurt or player == null:
		can_attack = true
		can_move = true
		return

	var to_player := player.global_position - global_position
	if to_player.length() > ATTACK_RADIUS:
		can_attack = true
		can_move = true
		return

	# --- Pattern: Atk3(if high) or Atk1 -> Atk2 (Finisher) ---
	if SOA != 2:
		if to_player.y < -2:
			play_anim("attack3") # ท่าโจมตีงัดขึ้น หรือ ท่าพิเศษ
		else:
			play_anim("attack1") # ท่าปกติ
		SOA += 1
	else:
		play_anim("attack2") # ท่าปิดคอมโบ
		SOA = 0

	if animation and is_inside_tree():
		await animation.animation_finished

	if not death and not is_hurt:
		can_move = true
		can_attack = true

# ===============================
# BOSS SKILLS
# ===============================
func _enter_rage():
	enraged = true
	SPEED *= 1.5
	atk1dmg += 10
	atk2dmg += 15
	atk3dmg += 10
	summon_timer = 1.0
	
	modulate = Color(1.5, 0.5, 0.5)
	print(">>> BOSS 4 ENRAGED <<<")
	
func _try_summon():
	# เสกไม่อั้น (Unlimited)
	if summon_scenes.is_empty():
		return

	play_anim("attack1") # ใช้ท่า 1 เรียกเพื่อน

	for i in range(2):
		var scene: PackedScene = summon_scenes.pick_random()
		var minion = scene.instantiate()

		var angle = randf() * TAU
		var offset = Vector2(cos(angle), sin(angle)) * (summon_radius + randf() * 20.0)
		minion.global_position = global_position + offset

		get_tree().current_scene.call_deferred("add_child", minion)

	print("BOSS 4 SUMMONED 2 MINIONS")

# ===============================
# ANIMATION & COLLISIONS
# ===============================
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		drop_item()
		$Area2D.set_deferred("disable", false)
		queue_free()
	elif anim_name == "hurt":
		is_hurt = false
		if not death:
			can_move = true
			can_attack = true
	
	_disable_collision()

func play_anim(name: String) -> void:
	if animation and animation.current_animation != name:
		animation.play(name)

func _disable_collision():
	# ใช้ has_node เพื่อความปลอดภัย
	$Sprite2D/HBArea2D/atk1.set_deferred("disabled",true)
	$Sprite2D/Area2D/atk2.set_deferred("disabled",true)
	$Sprite2D/Area2D2/atk3.set_deferred("disabled",true)

# 1. Body Damage
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and health > 0:
		var target_player = area.get_parent()
		if target_player.is_invincible == false:
			target_player.health -= bodydmg
			show_damage_to_player(bodydmg, target_player)

# 2. Attack 1
func _on_atk_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody"):
		var target_player = area.get_parent()
		if target_player.is_invincible == false:
			target_player.health -= atk1dmg
			show_damage_to_player(atk1dmg, target_player)

# 3. Attack 2
func _on_atk_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody"):
		var target_player = area.get_parent()
		if target_player.is_invincible == false:
			target_player.health -= atk2dmg
			show_damage_to_player(atk2dmg, target_player)

# 4. Attack 3
func _on_atk_3_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody"):
		var target_player = area.get_parent()
		if target_player.is_invincible == false:
			target_player.health -= atk3dmg
			show_damage_to_player(atk3dmg, target_player)

func drop_item():
	var scene: PackedScene = preload("res://Pickup/pickups.tscn")
	var dropA = scene.instantiate()
	dropA.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", dropA)
	print(">>> CALL DROP_ITEM <<<")

func show_damage(amount: int):
	var DamagePopup = preload("res://Animation5+3/DamagePopUp.tscn")
	var popup = DamagePopup.instantiate()
	get_tree().current_scene.add_child(popup)
	popup.global_position = global_position + Vector2(10, 10)
	
	if damaged:
		popup.set_text(str(amount), Color.WHITE)
	else:
		popup.set_text(str(amount), Color.RED)

# ⭐ เพิ่มฟังก์ชันนี้ให้ (Boss ตัวเดิมขาดไป)
func show_damage_to_player(amount: int, target: Node2D):
	var popup_scene = preload("res://Animation5+3/DamagePopUp.tscn")
	var popup = popup_scene.instantiate()
	get_tree().current_scene.add_child(popup)
	popup.global_position = target.global_position + Vector2(0, -20)
	popup.set_text(str(amount), Color.RED)

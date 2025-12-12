extends CharacterBody2D

@export var SPEED: float = 70
@export var STOP_RADIUS: float = 26.0          # ระยะที่หยุด ไม่ยืนทับผู้เล่น
@export var ATTACK_RADIUS: float = 26.0        # ระยะโจมตี
@export var ATTACK_DELAY: float = 0.5          # หน่วงก่อนฟัน
@export var DETECT_RADIUS: float = 220.0       # ระยะที่เริ่มเห็นผู้เล่น
@export var IDLE_CHANGE_TIME: float = 1.5      # เปลี่ยนทิศเดินมั่วทุกกี่วิ
var PreHealth = 0
var damaged := false
# --- Exposed NodePaths ---
@export var gfx_path: NodePath
@export var anim_path: NodePath
@export var area_path: NodePath

#--- Monster Setup -----
@export var health := 100
@export var atk1dmg : int = 20
@export var atk2dmg : int = 20
@export var bodydmg : int = 10

# --- Auto refs ---
var gfx: Node2D
var animation: AnimationPlayer
var area: Area2D


var player: Node2D = null
var last_dir := Vector2.RIGHT

var death := false
var is_hurt := false
var can_move := true
var can_attack := true

# --- AI state ---
enum State { IDLE, CHASE, ATTACK }
var state: int = State.IDLE
var idle_dir := Vector2.ZERO
var idle_timer := 0.0
var SOA := 0

func _ready() -> void:
	randomize()
	PreHealth = health
	_disable_collision()

	if gfx_path != NodePath():
		gfx = get_node(gfx_path) as Node2D
	else:
		push_warning("Orc: 'gfx_path' not assigned.")

	if anim_path != NodePath():
		animation = get_node(anim_path) as AnimationPlayer
	else:
		push_warning("Orc: 'anim_path' not assigned.")

	if area_path != NodePath():
		area = get_node(area_path) as Area2D
	else:
		push_warning("Orc: 'area_path' not assigned.")

	
	await get_tree().process_frame
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as Node2D

	$Bar.max_value = health
	$Bar.size = Vector2(20.375,2.0)
	$Bar.position = Vector2(-10.0,-12.0)
	_set_idle_dir()
	play_anim("idle")
	

func _physics_process(delta: float) -> void:
	$Bar.value = health
	damaged= false
	if health <= 0:
			death = true
			is_hurt = false
			can_attack = false
			can_move = false
			play_anim("death")

	if PreHealth != health:
		damaged = true
		show_damage(PreHealth - health)
		PreHealth = health

		# ตอนนี้ถ้ามอนตาย ให้โชว์ damage แล้วค่อยเข้าสู่ death state
		if health <= 0 and not death:
			death = true
			is_hurt = false
			can_attack = false
			can_move = false
			play_anim("death")
			return   # <<< ออกจากฟังก์ชันหลังตาย
		else:
			# ยังไม่ตาย → เล่นท่า hurt
			is_hurt = true
			can_move = false
			can_attack = false
			if animation:
				animation.play("hurt")
	

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

	# flip หันหน้าหาผู้เล่น
	if absf(to_player.x) > 0.01 and gfx:
		var sx: float = absf(gfx.scale.x)
		gfx.scale.x = -sx if to_player.x < 0.0 else sx

	# --- เลือก state ตามระยะ ---
	if dist > DETECT_RADIUS:
		state = State.IDLE
	elif dist > ATTACK_RADIUS:
		state = State.CHASE
	else:
		state = State.ATTACK

	# --- ทำพฤติกรรมแต่ละ state ---
	match state:
		State.IDLE:
			_do_idle(delta)
		State.CHASE:
			_do_chase(to_player)
		State.ATTACK:
			_do_attack(to_player)

	move_and_slide()


# ---------- STATE BEHAVIOUR ----------

func _do_idle(delta: float) -> void:
	idle_timer -= delta
	if idle_timer <= 0.0:
		_set_idle_dir()

	velocity = idle_dir * SPEED * 0.4  # เดินช้ากว่า chase หน่อย
	if idle_dir == Vector2.ZERO:
		play_anim("idle")
	else:
		play_anim("walk")


func _set_idle_dir() -> void:
	idle_timer = IDLE_CHANGE_TIME + randf() * 0.8
	# 30% โอกาสยืนเฉย ๆ
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

	# ดูว่าโจมตีแนวนอนหรือแนวตั้ง
	var axis_side: bool = (absf(to_player.x) - 10.0) >= absf(to_player.y)
	_start_attack(axis_side)


# ---------- ATTACK ----------

func _start_attack(axis_side: bool) -> void:
	attack_coroutine(axis_side)  # แยกไปเป็น coroutine ชัด ๆ


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

	
	# --- เลือกท่าโจมตี ---
	
	if SOA != 2:
		play_anim("attack1")
		SOA += 1
	else:
		play_anim("attack2")
		SOA = 0
	# รออนิเมชั่นจบ
	if animation and is_inside_tree():
		await animation.animation_finished

	if not death and not is_hurt:
		can_move = true
		can_attack = true



# ---------- DAMAGE / ANIMATION ----------




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		drop_item()
		queue_free()
	elif anim_name == "hurt":
		is_hurt = false
		if not death:
			can_move = true
			can_attack = true


func play_anim(name: String) -> void:
	if animation and animation.current_animation != name:
		animation.play(name)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and area.get_parent().is_invincible == false and health > 0:
		area.get_parent().health -= bodydmg
		show_damage(bodydmg)
func _on_atk_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and area.get_parent().is_invincible == false:
		area.get_parent().health -= atk1dmg
		show_damage(atk1dmg)

func _on_atk_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and area.get_parent().is_invincible == false:
		area.get_parent().health -= atk2dmg
		show_damage(atk2dmg)
func drop_item():
	var scene: PackedScene = preload("res://Pickup/pickups.tscn")
	var dropA = scene.instantiate()
	# ปรับตัวเลข Vector2(x, y) จนกว่าจะตรงใจ
	dropA.global_position = global_position + Vector2(-30, 20)

	get_tree().current_scene.call_deferred("add_child", dropA)
	print(">>> CALL DROP_ITEM <<<")
	
func _disable_collision():
	$Sprite2D/HBArea2D/atk1.set_deferred("disabled",true)
	$Sprite2D/Area2D/atk2.set_deferred("disabled",true)

func show_damage(amount: int):
	var DamagePopup = preload("res://Animation5+3/DamagePopUp.tscn")
	var popup = DamagePopup.instantiate()
	get_tree().current_scene.add_child(popup)

	popup.global_position = global_position + Vector2(10, 10)
	if damaged:
		popup.set_text(str(amount), Color.WHITE) 
	else:
		popup.set_text(str(amount), Color.RED) 
		

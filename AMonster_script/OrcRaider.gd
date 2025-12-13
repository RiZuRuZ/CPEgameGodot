extends CharacterBody2D

@export var SPEED: float = 50.0
@export var STOP_RADIUS: float = 26.0
@export var ATTACK_RADIUS: float = 40.0
@export var ATTACK_DELAY: float = 0.5
@export var DETECT_RADIUS: float = 220.0
@export var IDLE_CHANGE_TIME: float = 1.5
var PreHealth = 0
var damaged := false

@export var gfx_path: NodePath
@export var anim_path: NodePath
@export var area_path: NodePath

@export var health := 100
@export var atk1dmg : int = 20
@export var atk2dmg : int = 20
@export var atk3dmg : int = 20
@export var bodydmg : int = 10


var gfx: Node2D
var animation: AnimationPlayer
var area: Area2D

var player: Node2D = null
var last_dir := Vector2.RIGHT

var death := false
var is_hurt := false
var can_move := true
var can_attack := true

# ★★ NEW: กันไม่ให้ flip ระหว่างตี
var is_attacking: bool = false


enum State { IDLE, CHASE, ATTACK }
var state: int = State.IDLE
var idle_dir := Vector2.ZERO
var idle_timer := 0.0
var SOA := 0

var attack_motion := {
	"attack1": false,
	"attack2": true,
	"attack3": true
}

func _ready() -> void:
	randomize()
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
	$Bar.size = Vector2(20.375,2.0)
	$Bar.position = Vector2(-10.0,-12.0)
	_set_idle_dir()
	play_anim("idle")


func _physics_process(delta: float) -> void:
	$Bar.value = health

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
		elif not death:  # ★ แก้ไข 1: เปลี่ยนจาก else เป็น elif เพื่อกันไม่ให้เล่นท่า hurt ซ้ำตอนตายแล้ว
			# ยังไม่ตาย → เล่นท่า hurt
			is_hurt = true
			can_move = false
			can_attack = false
			if animation:
				animation.play("hurt")

	# ★ แก้ไข 2 (สำคัญที่สุด): ถ้าตายแล้ว ให้หยุดการทำงานทันที เพื่อไม่ให้ระบบ AI ไปสั่งเปลี่ยน Animation อื่น
	if death:
		return

	if is_hurt:
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

	# ★★ NEW: flip เฉพาะตอนที่ไม่กำลังตี
	if not is_attacking and absf(to_player.x) > 0.01 and gfx:
		var sx: float = absf(gfx.scale.x)
		gfx.scale.x = -sx if to_player.x < 0.0 else sx

	# --- เลือก state ---
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

	move_and_slide()


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
	if not can_attack:
		return

	can_attack = false
	can_move = false
	is_attacking = true  # ★★ NEW: เริ่มตี

	var chosen := ""
	if SOA != 2:
		if to_player.length() < ATTACK_RADIUS - 3:
			chosen = "attack1"
		else:
			chosen = "attack2"
		SOA += 1
	else:
		chosen = "attack3"
		SOA = 0

	if attack_motion.get(chosen, false) == false:
		velocity = Vector2.ZERO
	else:
		velocity = to_player.normalized() * SPEED * 0.6

	state = State.ATTACK  

	play_anim(chosen)
	_start_attack(chosen)


func _start_attack(anim_name: String) -> void:
	attack_coroutine(anim_name)


func attack_coroutine(anim_name: String) -> void:
	await get_tree().create_timer(ATTACK_DELAY).timeout

	if death or is_hurt:
		can_attack = true
		can_move = true
		is_attacking = false   # ★★ NEW
		return

	var to_player := player.global_position - global_position
	if to_player.length() > ATTACK_RADIUS:
		can_attack = true
		can_move = true
		is_attacking = false   # ★★ NEW
		return

	if animation and is_inside_tree():
		await animation.animation_finished

		is_attacking = false   # ★★ NEW
		if death:
			return
	if not death and not is_hurt:
		can_move = true
		can_attack = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		drop_item()
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


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and area.get_parent().is_invincible == false and health > 0:
		area.get_parent().health -= bodydmg


func _on_atk_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and area.get_parent().is_invincible == false:
		area.get_parent().health -= atk1dmg


func _on_atk_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and area.get_parent().is_invincible == false:
		area.get_parent().health -= atk2dmg


func _on_atk_3_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBody") and area.get_parent().is_invincible == false:
		area.get_parent().health -= atk3dmg


func drop_item():
	var scene: PackedScene = preload("res://Pickup/pickups.tscn")
	var dropA = scene.instantiate()
	dropA.global_position = global_position + Vector2(0, 0)
	get_tree().current_scene.call_deferred("add_child", dropA)
	print(">>> CALL DROP_ITEM <<<")
	

func _disable_collision():
	$Sprite2D/atk1/atk1.set_deferred("disabled",true)
	$Sprite2D/atk2/atk2.set_deferred("disabled",true)
	$Sprite2D/atk3/atk3_1.set_deferred("disabled",true)
	$Sprite2D/atk3/area3_2.set_deferred("disabled",true)

func show_damage(amount: int):
	var DamagePopup = preload("res://Animation5+3/DamagePopUp.tscn")
	var popup = DamagePopup.instantiate()
	get_tree().current_scene.add_child(popup)

	popup.global_position = global_position + Vector2(10, 10)
	if damaged:
		popup.set_text(str(amount), Color.WHITE) 
	else:
		popup.set_text(str(amount), Color.RED) 

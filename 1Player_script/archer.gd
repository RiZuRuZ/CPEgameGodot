extends CharacterBody2D

var SPEED: float = 100.0

var motion := Vector2.ZERO
#monter,position
#var SlimeScene = preload("res://Animation5+3/Slime.tscn")
#var SkeletonScene = preload("res://Animation5+3/Skeleton.tscn")
#Arrow damage
# Exposed NodePaths (set in the Inspector)
@export var gfx_path: NodePath
@export var anim_path: NodePath
@export var area_path: NodePath
@export var arrow_spawnR_path: NodePath
@export var arrow_spawnL_path: NodePath

var PreHealth = 0
var damaged:=false

# player setup
@export var health : int = 100
@export var arrow1dmg : int = 20
@export var arrow2dmg : int = 50
@export var Heal_time :int = 15
var time =0
@onready var lvlstat = $"/root/LevelSave"
var MaxHealth :int = 0
var preupheal
var preupspd
var preupdmg
# Auto-assigned references
var gfx: Node2D
var animation: AnimationPlayer
var area: Area2D

# Movement / state control
var can_move := true
var is_attacking := false
var is_hurt := false
var death := false

@export var INVINCIBLE_TIME: float = 1.0
var is_invincible := false   # อมตะ?

@onready var arrow_scene = preload("res://AProjectile/Arrow2.tscn")
var arrow_spawnR: Marker2D
var arrow_spawnL: Marker2D
var pending_shot := false
# ==========================
#  XP / LEVEL SYSTEM (FIXED)
# ==========================
var XP : int:
	set(value):
		XP = value
		%XP.value = value        # UI bar
var total_XP : int = 0  # XP สะสมรวมทั้งหมด
var level : int = 1:
	set(value):
		level = value
		%Level.text = "Lv " + str(value)
@export var baseupdmg :int
@export var baseupspd :int
@export var baseuphealth :int
# ==========================
#  SFX
# ==========================
@onready var sfx_lv_up: AudioStreamPlayer = $SFX_Lv_up
@onready var sfx_hurt: AudioStreamPlayer = $SFX_hurt
@onready var sfx_arrow: AudioStreamPlayer = $SFX_arrow
@onready var sfx_arrow_m_2: AudioStreamPlayer = $SFX_arrow_m2


func _ready() -> void:
	# รอ 1 เฟรม ให้ Animation / Scene ทุกอย่างโหลดเสร็จ
	preupheal =lvlstat.Mutihealth
	preupspd=lvlstat.Mutispeed
	preupdmg=lvlstat.Mutidam
	MaxHealth += health + (lvlstat.Mutihealth-1)*baseuphealth
	health = MaxHealth
	PreHealth = health
	arrow1dmg += baseupdmg*(lvlstat.Mutidam-1)
	arrow2dmg += baseupdmg*(lvlstat.Mutidam-1)
	SPEED += baseupspd*(lvlstat.Mutispeed-1)
	%Bar.value = health
	%Bar.max_value = MaxHealth
	%XP.value = lvlstat.progress
	await get_tree().process_frame
	_disable_collision()
	
	# --- gfx / anim ---
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

	# --- player hurtbox ---
	if area_path != NodePath():
		area = get_node(area_path) as Area2D
		area.area_entered.connect(_on_area_2d_area_entered)
	else:
		push_warning("⚠️ 'area_path' not assigned for player hurtbox.")

	arrow_spawnR = get_node(arrow_spawnR_path)
	arrow_spawnL = get_node(arrow_spawnL_path)
	

func _physics_process(delta: float) -> void:
	time += delta
	if health != MaxHealth and time >= Heal_time:
		health +=  1 * lvlstat.Mutiregen
		PreHealth = health
		show_damage(1 * lvlstat.Mutiregen)
		time = 0
	if level >= 7:
			%XP.max_value = 40
	elif level >= 3:
			%XP.max_value = 20
	check_XP()
	$"/root/LevelSave".progress = XP
	$"/root/LevelSave".level = level
#	check when stat is change ==============================
	if preupdmg != lvlstat.Mutidam and lvlstat.Mutidam !=1:
		arrow1dmg += baseupdmg
		arrow2dmg += baseupdmg
		preupdmg = lvlstat.Mutidam
#		==================================================
	if preupheal != lvlstat.Mutihealth and lvlstat.Mutihealth !=1:
		MaxHealth += baseuphealth
		preupheal = lvlstat.Mutihealth
	if preupspd != lvlstat.Mutispeed and lvlstat.Mutispeed !=1:
		SPEED += baseupspd
		preupspd = lvlstat.Mutispeed
	%Bar.value = health
	%Bar.max_value = MaxHealth
	motion = Vector2.ZERO
	if health <= 0:
		death = true
		can_move = false
		is_hurt = false
				
		if animation:
				animation.play("death")
				get_tree().change_scene_to_file("res://Gameover/gameover.tscn")
	#if is_hurt:
		#return
	damaged= false
	if PreHealth != health:
		damaged= true
		PreHealth=health
		if damaged:
			print("Player hit! Health:", health)

			if health <= 0 and not death:
				death = true
				can_move = false
				is_hurt = false
				
				if animation:
					animation.play("death")
					get_tree().change_scene_to_file("res://Gameover/gameover.tscn")

			elif not death:
				is_hurt = true
				can_move = false
				is_attacking = false
				_disable_collision()
				
				if animation:
					animation.play("hurt")
					
				_start_invincibility()
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# หันตามเมาส์ทุกเฟรม (ถ้ายังมีชีวิตและขยับได้)
	_update_facing_to_mouse()
	
	# --- movement input ---
	if Input.is_action_pressed("right"): motion.x += 1
	if Input.is_action_pressed("left"):  motion.x -= 1
	if Input.is_action_pressed("down"):  motion.y += 1
	if Input.is_action_pressed("up"):    motion.y -= 1


	# --- attack inputs ---
	if Input.is_action_just_pressed("m1")and not is_attacking:
		_start_attack("attack1", false)
		_delayed_shoot(arrow1dmg,0)
	if Input.is_action_just_pressed("m2")and not is_attacking:
		_start_attack("attack2", true)
		_delayed_shoot(arrow2dmg,1)

	#if Input.is_action_just_pressed("q") and not is_attacking:
		#_start_attack("attack3", true)
		#_delayed_shoot()

	# --- movement (ใช้ velocity + move_and_slide) ---
	if motion != Vector2.ZERO:
		motion = motion.normalized()
		velocity = motion * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
	# --- walk / idle animation ---
	if motion != Vector2.ZERO:
		if animation and animation.current_animation not in ["walk", "attack1", "attack2", "attack3", "hurt", "death"]:
			animation.play("walk")
	else:
		if animation and animation.current_animation not in ["idle", "attack1", "attack2", "attack3", "hurt", "death"]:
			animation.play("idle")


func _update_facing_to_mouse() -> void:
	if not gfx:
		return

	var mouse_pos: Vector2 = get_global_mouse_position()
	var sx: float = abs(gfx.scale.x)

	if mouse_pos.x < global_position.x:
		gfx.scale.x = -sx
	else:
		gfx.scale.x = sx


func _start_attack(anim_name: String, lock_movement: bool) -> void:
	is_attacking = true
	can_move = not lock_movement

#	if anim_name == "attack3":
#		pending_shot = true

	if animation:
		animation.play(anim_name)


func _on_anim_finished(anim_name: String) -> void:
	if anim_name in ["attack1", "attack2","attack3"]:
		is_attacking = false
		can_move = true
		_disable_collision()

#		if anim_name == "attack3" and pending_shot:
#			shoot_arrow()
#			pending_shot = false

	if anim_name == "hurt":
		sfx_hurt.play()
		is_hurt = false
		if not death:
			can_move = true
			

func _on_area_2d_area_entered(hit: Area2D) -> void:
	pass

func _on_area_2d_area_exited(hit: Area2D) -> void:
	SPEED = 100
			
func _start_invincibility() -> void:
	if is_invincible:
		return

	is_invincible = true
	
	if gfx:
		var original_modulate := gfx.modulate
		var blink_time := INVINCIBLE_TIME / 8.0

		for i in range(4):
			gfx.modulate.a = 0.3
			await get_tree().create_timer(blink_time).timeout

			gfx.modulate.a = 1.0
			await get_tree().create_timer(blink_time).timeout

		gfx.modulate = original_modulate

	is_invincible = false
	_disable_collision()

func _delayed_shoot(dmg,which) -> void:
	if which == 0:
		await await get_tree().create_timer(0.6).timeout
		sfx_arrow.play()
	elif which == 1:
		await await get_tree().create_timer(1).timeout
		sfx_arrow_m_2.play()
	# เช็คเผื่อถูกขัด เช่น โดนโจมตี หรือตายก่อน
	if death or is_hurt:
		return

	shoot_arrow(dmg,which)
	
func shoot_arrow(dmg,which):
	var arrow := arrow_scene.instantiate() as Area2D
	var mouse_pos: Vector2 = get_global_mouse_position()

	# ใส่ลูกศรเข้า scene ก่อน
	get_parent().add_child(arrow)
	arrow.damage = dmg
	arrow.check = which
	if which == 1:
		arrow.scale *=2.5
		
	# เลือกจุด spawn ซ้าย/ขวา
	var spawn_pos: Vector2
	if mouse_pos.x < global_position.x:
		spawn_pos = arrow_spawnL.global_position
	else:
		spawn_pos = arrow_spawnR.global_position

	# เซ็ตตำแหน่งเริ่ม
	arrow.global_position = spawn_pos

	# ให้ทิศทางยิงออกจากจุด spawn จริง ๆ
	var dir := (mouse_pos - spawn_pos).normalized()
	arrow.setup(dir) 


func _disable_collision():
	pass
	

# ==========================
#  XP SYSTEM FUNCTIONS
# ==========================
func gain_XP(amount):
	XP += amount
	total_XP += amount
	print("XP:", XP)
	$"/root/LevelSave".progress = XP

func check_XP() -> void:
	if XP >= %XP.max_value:
		sfx_lv_up.play()
		XP -= %XP.max_value
		level += 1
		$"/root/LevelSave".progress = XP
		$"/root/LevelSave".level = level


func _on_magnet_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
	if area.has_method("follow"):
		area.follow(self)
		
func show_damage(amount: int):
	var DamagePopup = preload("res://Animation5+3/DamagePopUp.tscn")
	var popup = DamagePopup.instantiate()
	get_tree().current_scene.add_child(popup)

	popup.global_position = global_position + Vector2(10, 10)
	popup.set_text(str(amount), Color.GREEN)

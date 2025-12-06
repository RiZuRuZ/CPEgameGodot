extends CharacterBody2D

var SPEED: float = 100.0
var motion := Vector2.ZERO
#monter,position
#var SlimeScene = preload("res://Animation5+3/Slime.tscn")
#var SkeletonScene = preload("res://Animation5+3/Skeleton.tscn")
var PreHealth = 0
var damaged := false	

# Exposed NodePaths (set in the Inspector)

# ==========================
#  NodePaths
# ==========================
@export var gfx_path: NodePath
@export var anim_path: NodePath
@export var area_path: NodePath
@export var arrow_spawnR_path: NodePath
@export var arrow_spawnL_path: NodePath

# Auto refs
var gfx: Node2D
var animation: AnimationPlayer
var area: Area2D

# ==========================
#  State
# ==========================
var can_move := true
var is_attacking := false
var is_hurt := false
var health := 100
var death := false

@export var INVINCIBLE_TIME: float = 1.0
var is_invincible := false

@onready var arrow_scene = preload("res://AProjectile/Arrow1.tscn")
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

		if value >= 7:
			%XP.max_value = 40
		elif value >= 3:
			%XP.max_value = 20




# ==========================
#  READY
# ==========================
func _ready() -> void:
	PreHealth = health
	# รอ 1 เฟรม ให้ Animation / Scene ทุกอย่างโหลดเสร็จ
	await get_tree().process_frame
	_disable_collision()
	
	if gfx_path != NodePath():
		gfx = get_node(gfx_path)
	if anim_path != NodePath():
		animation = get_node(anim_path)
	if area_path != NodePath():
		area = get_node(area_path)

	if animation:
		animation.animation_finished.connect(_on_anim_finished)

	arrow_spawnR = get_node(arrow_spawnR_path)
	arrow_spawnL = get_node(arrow_spawnL_path)

	$Bar.max_value = health


# ==========================
#  PHYSICS PROCESS
# ==========================
func _physics_process(delta: float) -> void:
	$Bar.value = health
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

	_update_facing_to_mouse()

	# movement
	if Input.is_action_pressed("right"): motion.x += 1
	if Input.is_action_pressed("left"):  motion.x -= 1
	if Input.is_action_pressed("down"):  motion.y += 1
	if Input.is_action_pressed("up"):    motion.y -= 1

	# attacks
	if Input.is_action_just_pressed("m1"):
		_start_attack("attack1", false)
	if Input.is_action_just_pressed("q"):
		_start_attack("attack2", true)
		return
	if Input.is_action_just_pressed("m2") and not is_attacking:
		_start_attack("attack3", true)
		_delayed_shoot()

	# movement apply
	if motion != Vector2.ZERO:
		motion = motion.normalized()
		velocity = motion * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# animations
	if motion != Vector2.ZERO:
		if animation and animation.current_animation not in ["walk", "attack1", "attack2", "attack3", "hurt", "death"]:
			animation.play("walk")
	else:
		if animation and animation.current_animation not in ["idle", "attack1", "attack2", "attack3", "hurt", "death"]:
			animation.play("idle")

	check_XP()



# ==========================
#  Attack + Animation
# ==========================
func _update_facing_to_mouse() -> void:
	if not gfx:
		return

	var mouse_pos = get_global_mouse_position()
	var sx = abs(gfx.scale.x)

	gfx.scale.x = -sx if mouse_pos.x < global_position.x else sx


func _start_attack(anim_name: String, lock_movement: bool) -> void:
	is_attacking = true
	can_move = not lock_movement

	if animation:
		animation.play(anim_name)


func _on_anim_finished(anim_name: String) -> void:
	if anim_name in ["attack1", "attack2", "attack3"]:
		is_attacking = false
		can_move = true
		_disable_collision()

	if anim_name == "hurt":
		is_hurt = false
		if not death:
			can_move = true



# ==========================
#  Damage & Invincibility
# ==========================
func _on_area_2d_area_entered(hit: Area2D) -> void:
	# ตายหรืออมตะ → ไม่โดนดาเมจ
	#if death or is_invincible:
		#return
#
	#var damaged := false
#
	#if hit.is_in_group("Enemy10DMG"):
		#health -= 10
		#damaged = true
	#elif hit.is_in_group("Enemy15DMG"):
		#health -= 15
		#damaged = true
	#elif hit.is_in_group("Enemy20DMG"):
		#health -= 20
		#damaged = true
	#elif hit.is_in_group("Enemy25DMG"):
		#health -= 25
		#damaged = true
	#elif hit.is_in_group("Enemy30DMG"):
		#health -= 30
		#damaged = true
	#elif hit.is_in_group("Enemy35DMG"):
		#health -= 35
		#damaged = true
	#elif hit.is_in_group("Enemy40DMG"):
		#health -= 40
		#damaged = true
	#elif hit.is_in_group("EnemyBody"):
		#health -= 10
		#damaged = true
	#elif hit.is_in_group("slow"):
		#SPEED = 50
		#return   # ไม่ต้องไปเช็คดาเมจต่อ (ถ้า slow เป็นโซนสิ่งแวดล้อมธรรมดา)
#
	#if damaged:
		#print("Player hit! Health:", health)
#
		#if health <= 0 and not death:
			#death = true
			#can_move = false
			#is_hurt = false
			#
			#if animation:
				#animation.play("death")
				#$"/root/Wave/CanvasLayer".visible = false
				#get_tree().change_scene_to_file("res://Gameover/gameover.tscn")
#
		#else:
			#is_hurt = true
			#can_move = false
			#is_attacking = false
			#_disable_collision()
			#
			#if animation:
				#animation.play("hurt")
				#
			#_start_invincibility()
	pass
func _on_area_2d_area_exited(hit: Area2D) -> void:
	SPEED = 100


func _start_invincibility() -> void:
	if is_invincible:
		return

	is_invincible = true

	if gfx:
		var blink_time = INVINCIBLE_TIME / 8.0
		for i in range(4):
			gfx.modulate.a = 0.3
			await get_tree().create_timer(blink_time).timeout

			gfx.modulate.a = 1.0
			await get_tree().create_timer(blink_time).timeout

	is_invincible = false
	_disable_collision()



# ==========================
#  Arrow Shooting
# ==========================
func _delayed_shoot() -> void:
	await get_tree().create_timer(0.7).timeout
	if death or is_hurt:
		return
	shoot_arrow()


func shoot_arrow():
	var arrow = arrow_scene.instantiate()
	get_parent().add_child(arrow)

	var mouse_pos = get_global_mouse_position()
	var spawn_pos = arrow_spawnL.global_position if mouse_pos.x < global_position.x else arrow_spawnR.global_position

	arrow.global_position = spawn_pos
	var dir = (mouse_pos - spawn_pos).normalized()
	arrow.setup(dir)



# ==========================
#  Collision Disable
# ==========================
func _disable_collision():
	$CharacterBody2D/Soldier/atk1/CollisionPolygon2D.set_deferred("disabled",true)
	$CharacterBody2D/Soldier/Area2D2/CollisionShape2D.set_deferred("disabled",true)
	
	


func _on_atk_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnemyBody") :
		area.get_parent().health -= 1000


func _on_area_2d_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnemyBody") :
		area.get_parent().health -= 30



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
		XP -= %XP.max_value
		level += 1
		$"/root/LevelSave".progress = XP
		$"/root/LevelSave".level = level

# ==========================
#  MAGNET PICKUP
# ==========================
func _on_magnet_area_entered(area: Area2D) -> void:
	if area.has_method("follow"):
		area.follow(self)

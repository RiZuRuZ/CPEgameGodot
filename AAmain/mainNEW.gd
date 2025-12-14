extends Node

var wave_timer: Timer = null
var state_time: Timer = null
@export var SLIME : PackedScene
@export var SKELETON : PackedScene
@export var ORC : PackedScene
@export var ARCHERSKELETON : PackedScene
@export var ARMOREDORC : PackedScene
@export var ARMOREDSKELETON : PackedScene
@export var ELITEORC : PackedScene
@export var GREATSWORDSKELETON : PackedScene
@export var ORCRIDER : PackedScene
@export var WEREBARE : PackedScene
@export var WEREWOLF : PackedScene
@export var BOSS1 : PackedScene
@export var BOSS2 : PackedScene
@export var BOSS3 : PackedScene
@export var BOSS4 : PackedScene

var PlayerScene
var stages := {}

var current_stage := 1
var current_wave := 1

# ขอบเขตอบ spawn zone
@export var safe_radius := 140
@export var spawn_radius := 150

# increase monsters stat
@export var Moredmg :int
@export var Morespd :int
@export var Morehealt :int

func _ready():
	# --- เก็บข้อมูล Stage → Waves --
	stages = {
		1: {
			1: [ [SLIME, 2], [SKELETON, 2] ],
			2: [ [SLIME, 1], [SKELETON, 2], [ORC, 1] ],
			3: [ [SLIME, 4], [SKELETON, 3], [ORC, 2] ],
			4: [ [ORC, 3], [SLIME, 2], [SKELETON, 4] ],
			5: [ [BOSS1, 1], [SLIME, 3], [SKELETON, 2] ]
		}
	}
	
	if $"/root/Wave".selection == 0:
		PlayerScene = preload("res://Animation5+3/Players/Soldier.tscn")
	elif $"/root/Wave".selection == 1:
		PlayerScene = preload("res://Animation5+3/Players/Swordman.tscn")
	elif $"/root/Wave".selection == 2:
		PlayerScene = preload("res://Animation5+3/Players/Armored Axeman.tscn")
	elif $"/root/Wave".selection == 3:
		PlayerScene = preload("res://Animation5+3/Players/Archer.tscn")
	elif $"/root/Wave".selection == 4:
		PlayerScene = preload("res://Animation5+3/Players/Wizard.tscn")
		
	var player = PlayerScene.instantiate()
	add_child(player)
	player.position = Vector2(470, 170)
	
	$"/root/Wave/CanvasLayer".visible = true
	$"/root/Wave".wave = str(current_wave)
	
	# รอ 10 วิ ก่อนเริ่มเกม
	await get_tree().create_timer(10).timeout
	
	# >>>> แก้ตรงนี้: เอา start_wave_loop ขึ้นก่อน <<<<
	start_wave_loop()       # สร้าง Timer มารอก่อน
	start_stage(current_stage) # แล้วค่อยเริ่ม Stage

# ------------------------------
# เริ่ม Stage
# ------------------------------
func start_stage(stage_number:int):
	current_stage = stage_number
	current_wave = 1
	print("Start Stage:", stage_number)
	_on_next_wave()

# ------------------------------
# วน Wave
# ------------------------------
func start_wave_loop():
	wave_timer = Timer.new()
	wave_timer.wait_time = 15.0
	wave_timer.autostart = true
	wave_timer.one_shot = false
	add_child(wave_timer)
	wave_timer.timeout.connect(_on_next_wave)

func _on_next_wave():
	$"/root/Wave/CanvasLayer/Label".visible = true
	$"/root/Wave/CanvasLayer/time".visible = true
	
	# >>> แก้ไข: รีเซ็ตเวลาสำหรับเวฟใหม่เป็น 15 วิ เสมอ (กันบัคจากรอบที่แล้วที่ถูกลดเหลือ 3) <<<
	wave_timer.start(15.0) 
	
	var wave_data = stages[current_stage]
	
	if not wave_data.has(current_wave):
		wave_timer.stop()
		$"/root/Wave/CanvasLayer/time".visible = false
	else:
		if wave_data != null:
			print("Wave", current_wave, "start!")
			spawn_wave(current_stage, current_wave)
			current_wave += 1
			
			# เช็คว่าหลังจากเวฟนี้ ยังมีเวฟต่อไหม ถ้าไม่มีก็หยุดเวลาเลย
			if not wave_data.has(current_wave):
				wave_timer.stop()
				$"/root/Wave/CanvasLayer/time".visible = false	
		else:
			get_tree().quit()

# ------------------------------
# spawn wave
# ------------------------------
func spawn_wave(stage:int, wave:int):
	var wave_info = stages[stage][wave]
	for enemy_data in wave_info:
		var enemy_scene = enemy_data[0]
		var amount = enemy_data[1]
		for i in range(amount):
			var enemy = enemy_scene.instantiate()
			enemy.health += Morehealt
			enemy.SPEED += Morespd
			if enemy.bodydmg: enemy.bodydmg += Moredmg
			if enemy.has_method("atk1dmg"): enemy.atk1dmg += Moredmg
			if enemy.has_method("atk2dmg"): enemy.atk2dmg += Moredmg
			if enemy.has_method("atk3dmg"): enemy.atk3dmg += Moredmg
			if enemy.has_method("arrowdmg"): enemy.arrowdmg += Moredmg
			enemy.global_position = random_spawn_position()
			add_child(enemy)

# ------------------------------
# สุ่มตำแหน่ง
# ------------------------------
func random_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.ZERO
		
	var player_pos = player.global_position
	var min_x = -448.0; var max_x = 493.0
	var min_y = -320.0; var max_y = 320.0
	var spawn_pos: Vector2
	
	while true:
		var rand_x = randf_range(min_x, max_x)
		var rand_y = randf_range(min_y, max_y)
		spawn_pos = Vector2(rand_x, rand_y)
		
		if player_pos.distance_to(spawn_pos) >= safe_radius and player_pos.distance_to(spawn_pos) <= spawn_radius:
			break
			
	return spawn_pos
	
func _physics_process(delta: float) -> void:
	var monster = get_tree().get_node_count_in_group("EnemyBody")
	
	if is_instance_valid(wave_timer):
		# อัปเดตเวลา UI
		$"/root/Wave".nextwave = wave_timer.time_left
		$"/root/Wave".wave = str(current_wave-1)
		
		# >>>> จุดสำคัญ: เช็คมอนหมด แล้วเร่งเวลา <<<<
		# ถ้ามอนสเตอร์หมด (0 ตัว) และเวลายังเหลือมากกว่า 3 วินาที และยังมีเวฟต่อไปรออยู่
		if monster == 0 and wave_timer.time_left > 3.0 and stages[current_stage].has(current_wave):
			print("All clear! Next wave in 3 seconds...")
			wave_timer.start(3.0) # บังคับให้นับถอยหลังใหม่เริ่มที่ 3 วิทันที
		# =======================================

	var player = get_tree().get_first_node_in_group("player")
	if player and player.health <= 0:
		$"/root/Wave/CanvasLayer/Label".visible = false
		$"/root/Wave/CanvasLayer/time".visible = false
		
	# เช็คจบ Stage (เงื่อนไขเดิมของคุณ)
	if monster == 0 and current_stage == 1 and current_wave > 5:
		print("Stage", current_stage, "Complete!")
		current_stage +=1
		$"/root/LevelSave".SaveMutihealth = $"/root/LevelSave".Mutihealth
		$"/root/LevelSave".SaveMutidam = $"/root/LevelSave".Mutidam
		$"/root/LevelSave".SaveMutispeed = $"/root/LevelSave".Mutispeed
		$"/root/LevelSave".SaveMutiregen = $"/root/LevelSave".Mutiregen
		$"/root/LevelSave".SaveLevel = $"/root/LevelSave".level
		$"/root/LevelSave".SaveMutiregen =  $"/root/LevelSave".Mutiregen
		$"/root/Wave".state = current_stage
		$"/root/Wave/CanvasLayer/Label".visible = false
		$"/root/Wave/CanvasLayer/time".visible = false
		$"/root/Wave/CanvasLayer/victory".visible = true

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
# โหลดมอน
var PlayerScene
#var SLIME
#var SKELETON 
#var ORC		
var stages := {}

var current_stage := 2
var current_wave := 1

# ขอบเขตอบ spawn zone
@export var safe_radius := 140
@export var spawn_radius := 150
# increase monsters stat more stage more difficle
@export var Morespd :int = 4
@export var Moredmg :int = 4
@export var Morehealt :int= 4

func _ready():
	# --- เก็บข้อมูล Stage → Waves --
	stages = {
		2: {
			1: [ [SLIME, 2], [SKELETON, 3], [ORC,5], [WEREWOLF,3] ],
			2: [ [SKELETON, 6],[ORC,8] , [WEREWOLF,5]  ],
			3: [ [SKELETON, 12],[ORC,10], [WEREWOLF,7],[ORCRIDER,1] ],
		}
	}
	#SLIME = preload(slime_paht)
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
	#player.add_to_group("player")
	player.position = Vector2(0, 0)
	$"/root/Wave/CanvasLayer".visible = true
	$"/root/Wave/CanvasLayer/Button".visible = false
	$"/root/Wave".wave = str(current_wave)
	player.XP = $"/root/LevelSave".progress
	player.level = $"/root/LevelSave".level
	current_stage = $"/root/Wave".state
	$"/root/Wave/CanvasLayer/victory".modulate = Color($"/root/Wave/CanvasLayer/victory".modulate.r, $"/root/Wave/CanvasLayer/victory".modulate.g,$"/root/Wave/CanvasLayer/victory".modulate.b, 1)
	start_stage(current_stage)
		

# ------------------------------
# เริ่ม Stage
# ------------------------------
func start_stage(stage_number:int):
	current_stage = stage_number
	current_wave = 1
	print("Start Stage:", stage_number)
	start_wave_loop()
# ------------------------------
# วน Wave ทุก 10 วิ หรือจนมอนตายหมด
# ------------------------------
func start_wave_loop():
	wave_timer = Timer.new()
	wave_timer.wait_time = 5.0
	wave_timer.autostart = true
	wave_timer.one_shot = false
	add_child(wave_timer)
	wave_timer.timeout.connect(_on_next_wave)
func _on_next_wave():
	$"/root/Wave/CanvasLayer/Label".visible = true
	$"/root/Wave/CanvasLayer/time".visible = true
	var wave_data = stages[current_stage]
	if not wave_data.has(current_wave):
		wave_timer.stop()
		$"/root/Wave/CanvasLayer/time".visible = false
	else:
		if wave_data != null:
			print("Wave", current_wave, "start!")
			spawn_wave(current_stage, current_wave)
			current_wave += 1
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
			if enemy.bodydmg:
				enemy.bodydmg += Moredmg
				print("increase")
			if enemy.has_method("atk1dmg"):
				enemy.atk1dmg += Moredmg
			if enemy.has_method("atk2dmg"):
				enemy.atk2dmg += Moredmg
			if enemy.has_method("atk3dmg"):
				enemy.atk3dmg += Moredmg
			if enemy.has_method("arrowdmg"):
				enemy.arrowdmg += Moredmg
			enemy.global_position = random_spawn_position()
			add_child(enemy)
# ------------------------------
# สุ่มตำแหน่งรอบ safe zone (spawn ring)
# ------------------------------
func random_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.ZERO

	var angle = randf() * TAU
	var radius = randf_range(safe_radius, spawn_radius)
	return player.global_position + Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	)
func _physics_process(delta: float) -> void:
	var monster = get_tree().get_node_count_in_group("EnemyBody")
	if is_instance_valid(wave_timer) and monster != 0:
		$"/root/Wave".nextwave = wave_timer.time_left
		$"/root/Wave".wave = str(current_wave-1)
	else:
		pass
	var player = get_tree().get_first_node_in_group("player")
	if player.health <= 0:
		$"/root/Wave/CanvasLayer/Label".visible = false
		$"/root/Wave/CanvasLayer/time".visible = false
	if monster == 0 and current_stage == 2 and current_wave > 3:
		print("Stage", current_stage, "Complete!")
		current_stage +=1
		$"/root/Wave".state = current_stage
		$"/root/Wave/CanvasLayer/Label".visible = false
		$"/root/Wave/CanvasLayer/time".visible = false
		$"/root/Wave/CanvasLayer/victory".visible = true		
	#print("current stage",current_stage)

extends Node

var wave_timer: Timer = null

# โหลดมอน
const PlayerScene = preload("res://Animation5+3/Soldier.tscn")
const SLIME     = preload("res://Animation5+3/Slime.tscn")
const SKELETON  = preload("res://Animation5+3/Skeleton.tscn")

# --- เก็บข้อมูล Stage → Waves --
var stages := {
	1: {
		1: [ [SLIME, 3], [SKELETON, 2] ],
		2: [ [SLIME, 3], [SKELETON, 3] ],
		3: [ [SLIME, 4], [SKELETON, 5] ],
	},
	2: {
		1: [ [SLIME, 5], [SKELETON, 3] ],
		2: [ [SLIME, 7], [SKELETON, 6] ],
		3: [ [SLIME, 10], [SKELETON, 12] ],
	}
}

var current_stage := 1
var current_wave := 1

# ขอบเขตอบ spawn zone
@export var safe_radius := 140
@export var spawn_radius := 150


func _ready():
	var player = PlayerScene.instantiate()
	add_child(player)
	player.add_to_group("player")
	player.position = Vector2(250, 150)
	start_stage(current_stage)
	$"/root/Wave".visible = true
	$"/root/Wave".wave = current_wave	

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
	var wave_data = stages[current_stage]

	if not wave_data.has(current_wave):
		print("Stage", current_stage, "Complete!")
		current_stage += 1
		#start_stage(current_stage)
		return

	print("Wave", current_wave, "start!")
	spawn_wave(current_stage, current_wave)
	current_wave += 1
	#$"/root/Wave".wave = current_wave	


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

			enemy.global_position = random_spawn_position()

			add_child(enemy)
			print("Spawned:", enemy.name)
			

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
	if is_instance_valid(wave_timer):
		$"/root/Wave".nextwave = wave_timer.time_left
		$"/root/Wave".wave = current_wave-1
	else:
		print("not found")

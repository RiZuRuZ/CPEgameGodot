extends Node2D

#const PlayerScene = preload("res://Animation5+3/Priest.tscn")
const PlayerScene = preload("res://Animation5+3/Soldier.tscn")
const Slimescene = preload("res://Animation5+3/Slime.tscn")
const Skeletonscene = preload("res://Animation5+3/Skeleton.tscn")
var wave = 0
var rng = RandomNumberGenerator.new()

@export var Wave_time:int
@export var FirstWave_time:int
@export var SafeZone:int
@export var SpawnZone:int

func EnemieSpawn () -> void:
	wave += 1
	print(wave)
	$"/root/Wave".wave = wave
	$wavetime.start()
	var total = 5*wave
	var Spawn_gap = Wave_time/total #second
	if Spawn_gap > 3:
		Spawn_gap = 3
	var Num_slime = floor(total*(0.7-0.2*(wave-1)))
	print(Num_slime)
	var Num_skeleton = total-Num_slime
	print(Num_skeleton)
	
	
	for i in Num_slime: #slime
		var Slime = Slimescene.instantiate()
		var prefix = rng.randf()
		var safe_x = rng.randf_range(-SafeZone,SafeZone)
		var safe_y
		if prefix >= 0.5:
			safe_y = sqrt(pow(SafeZone,2)-(pow(safe_x,2)))
		else:
			safe_y = -sqrt(pow(SafeZone,2)-(pow(safe_x,2)))
		var spawn_x = rng.randf_range(0,SpawnZone)
		var spawn_y = rng.randf_range(0,SpawnZone)
		if $Soldier:
			var Player = $Soldier
			add_child(Slime)
			if safe_x <= 0 and safe_y <=0:
				Slime.position = Vector2(Player.position.x+safe_x-spawn_x,Player.position.y+safe_y-spawn_y)
			elif safe_x <= 0 and safe_y >0:
				Slime.position = Vector2(Player.position.x+safe_x-spawn_x,Player.position.y+safe_y+spawn_y)
			elif safe_x > 0 and safe_y <=0:
				Slime.position = Vector2(Player.position.x+safe_x+spawn_x,Player.position.y+safe_y-spawn_y)
			else:
				Slime.position = Vector2(Player.position.x+safe_x+spawn_x,Player.position.y+safe_y+spawn_y)
			print(Slime.position)
			print("spawn slime")
		await get_tree().create_timer(Spawn_gap).timeout
	for i in Num_skeleton: #skeleton
		var Skeleton = Skeletonscene.instantiate()
		var prefix = rng.randf()
		var safe_x = rng.randf_range(-SafeZone,SafeZone)
		var safe_y
		if prefix >= 0.5:
			safe_y = sqrt(pow(SafeZone,2)-(pow(safe_x,2)))
		else:
			safe_y = -sqrt(pow(SafeZone,2)-(pow(safe_x,2)))
		var spawn_x = rng.randf_range(0,SpawnZone)
		var spawn_y = rng.randf_range(0,SpawnZone)
		if $Soldier:
			var Player = $Soldier
			add_child(Skeleton)
			if safe_x <= 0 and safe_y <=0:
				Skeleton.position = Vector2(Player.position.x+safe_x-spawn_x,Player.position.y+safe_y-spawn_y)
			elif safe_x <= 0 and safe_y >0:
				Skeleton.position = Vector2(Player.position.x+safe_x-spawn_x,Player.position.y+safe_y+spawn_y)
			elif safe_x > 0 and safe_y <=0:
				Skeleton.position = Vector2(Player.position.x+safe_x+spawn_x,Player.position.y+safe_y-spawn_y)
			else:
				Skeleton.position = Vector2(Player.position.x+safe_x+spawn_x,Player.position.y+safe_y+spawn_y)
			print(Skeleton.position)
			print("spawn skeleton")
		await get_tree().create_timer(Spawn_gap).timeout
	
	


func _ready() -> void:
	var label = $"/root/Wave"
	label.visible = true
	label.wave = wave
	var player = PlayerScene.instantiate()
	add_child(player)
	player.add_to_group("player")
	player.position = Vector2(250, 150)
	$first.wait_time = FirstWave_time
	$wavetime.wait_time = Wave_time
	$first.start()
	
	

	# optional if your scene structure matches
	#player.gfx_path = "CharacterBody2D/Soldier"
	#player.anim_path = "CharacterBody2D/AnimationPlayer"
	
func _on_first_timeout() -> void: #1st wave
	EnemieSpawn()
	



func _on_wavetime_timeout() -> void:
	#print(wave)
	#if wave == 2:
		#for i in 5: 
			#var Slime = Slimescrne.instantiate()
			#var prefix = rng.randf()
			#var safe_x = rng.randf_range(-70,70)
			#var safe_y
			#if prefix >= 0.5:
				#safe_y = sqrt(pow(70,2)-(pow(safe_x,2)))
			#else:
				#safe_y = -sqrt(pow(70,2)-(pow(safe_x,2)))
			#var spawn_x = rng.randf_range(0,100)
			#var spawn_y = rng.randf_range(0,100)
			#if $Soldier:
				#var Player = $Soldier
				#add_child(Slime)
				#if safe_x <= 0 and safe_y <=0:
					#Slime.position = Vector2(Player.position.x+safe_x-spawn_x,Player.position.y+safe_y-spawn_y)
				#elif safe_x <= 0 and safe_y >0:
					#Slime.position = Vector2(Player.position.x+safe_x-spawn_x,Player.position.y+safe_y+spawn_y)
				#elif safe_x > 0 and safe_y <=0:
					#Slime.position = Vector2(Player.position.x+safe_x+spawn_x,Player.position.y+safe_y-spawn_y)
				#else:
					#Slime.position = Vector2(Player.position.x+safe_x+spawn_x,Player.position.y+safe_y+spawn_y)
				#print(Slime.position)
				#print("spawn")
			#await get_tree().create_timer(1).timeout
		#$wavetime.start()
	#elif wave == 3:
		#
		#for i in 10: 
			#var Slime = Slimescrne.instantiate()
			#var prefix = rng.randf()
			#var safe_x = rng.randf_range(-70,70)
			#var safe_y
			#if prefix >= 0.5:
				#safe_y = sqrt(pow(70,2)-(pow(safe_x,2)))
			#else:
				#safe_y = -sqrt(pow(70,2)-(pow(safe_x,2)))
			#var spawn_x = rng.randf_range(0,100)
			#var spawn_y = rng.randf_range(0,100)
			#if $Soldier:
				#var Player = $Soldier
				#add_child(Slime)
				#if safe_x <= 0 and safe_y <=0:
					#Slime.position = Vector2(Player.position.x+safe_x-spawn_x,Player.position.y+safe_y-spawn_y)
				#elif safe_x <= 0 and safe_y >0:
					#Slime.position = Vector2(Player.position.x+safe_x-spawn_x,Player.position.y+safe_y+spawn_y)
				#elif safe_x > 0 and safe_y <=0:
					#Slime.position = Vector2(Player.position.x+safe_x+spawn_x,Player.position.y+safe_y-spawn_y)
				#else:
					#Slime.position = Vector2(Player.position.x+safe_x+spawn_x,Player.position.y+safe_y+spawn_y)
				#print(Slime.position)
				#print("spawn")
			#await get_tree().create_timer(1).timeout
		#$wavetime.start()
	#wave+=1
	#$"/root/Wave".wave = wave
	EnemieSpawn()
	
	
func _physics_process(delta: float) -> void:
	$"/root/Wave".nextwave = $wavetime.time_left
	

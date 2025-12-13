extends CanvasLayer
var state
var lvl
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = $"/root/Wave".state
	lvl = $"/root/LevelSave"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_retry_pressed() -> void:
	if state == 1:
		lvl.Mutihealth = 1
		lvl.Mutispeed=1
		lvl.Mutidam=1
		lvl.Mutiregen=1
		lvl.level = 1
		lvl.prelvl = 1
		get_tree().change_scene_to_file("res://Stage/main.tscn")
	elif  state == 2:
		lvl.Mutihealth =lvl.SaveMutihealth
		lvl.Mutispeed=lvl.SaveMutispeed
		lvl.Mutidam=lvl.SaveMutidam
		lvl.level =lvl.SaveLevel
		lvl.prelvl = lvl.SaveLevel
		lvl.Mutiregen = lvl.SaveMutiregen
		get_tree().change_scene_to_file("res://Stage/stage2.tscn")
		
	elif  state == 3:
		lvl.Mutihealth =lvl.SaveMutihealth
		lvl.Mutispeed=lvl.SaveMutispeed
		lvl.Mutidam=lvl.SaveMutidam
		lvl.level =lvl.SaveLevel
		lvl.prelvl = lvl.SaveLevel
		lvl.Mutiregen = lvl.SaveMutiregen
		get_tree().change_scene_to_file("res://Stage/stage3.tscn")
	elif  state == 4:
		lvl.Mutihealth = 1
		lvl.Mutispeed=1
		lvl.Mutidam=1
		lvl.Mutiregen=1
		lvl.level = 1
		lvl.prelvl = 1
		get_tree().change_scene_to_file("res://Ascenes/cutscene/ED2(bad).tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

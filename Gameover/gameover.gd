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
	lvl.Mutihealth = 1
	lvl.Mutispeed=1
	lvl.Mutidam=1
	if state == 1:
		get_tree().change_scene_to_file("res://Stage/main.tscn")
	elif  state == 2:
		get_tree().change_scene_to_file("res://Stage/stage2.tscn")
	elif  state == 3:
		get_tree().change_scene_to_file("res://Stage/stage3.tscn")
	elif  state == 4:
		get_tree().change_scene_to_file("res://Stage/stage4.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

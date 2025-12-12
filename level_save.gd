extends Control
var level =1
var progress = 0
var Mutihealth =1 
var Mutidam = 1
var Mutispeed=1
var SaveMutihealth =1 
var SaveMutidam = 1
var SaveMutispeed=1
var SaveLevel = 1
var prelvl
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CanvasLayer.hide()
	prelvl = level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if prelvl != level and level != 1:
		$CanvasLayer.show()
		prelvl = level
		await get_tree().process_frame
		get_tree().paused = true


func _on_health_pressed() -> void:
	Mutihealth +=1
	$CanvasLayer.hide()
	print(Mutihealth)
	get_tree().paused = false
func _on_speed_pressed() -> void:
	Mutispeed +=1
	$CanvasLayer.hide()
	print(Mutispeed)
	get_tree().paused = false
func _on_damage_pressed() -> void:
	Mutidam +=1
	$CanvasLayer.hide()
	print(Mutidam)
	get_tree().paused = false


func _on_regen_pressed() -> void:
	Mutiregen +=1
	$CanvasLayer.hide()
	print(Mutiregen)
	get_tree().paused = false

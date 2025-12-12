extends Control

@onready var pause_button: VBoxContainer = $Panel/PauseButton
@onready var options: Panel = $Options

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	pause_button.visible = true
	options.visible = false
	get_tree().paused = false

func pause():
	show()
	pause_button.visible = true
	options.visible = false
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()

func testesc():
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()

func _on_resume_pressed() -> void:
	resume()

func _on_option_pressed() -> void:
	pause_button.visible = false
	print(pause_button.visible)
	options.visible = true

func _on_quiz_pressed() -> void:
	get_tree().quit()

func _process(delta):
	testesc()

func _on_back_pressed() -> void:
	pause_button.visible = true
	options.visible = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_area_2d_area_exited(area: Area2D) -> void:
	pass # Replace with function body.

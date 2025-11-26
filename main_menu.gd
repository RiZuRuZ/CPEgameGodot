extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options

var tween:Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true
	options.visible = false
	await get_tree().process_frame
	$Label.pivot_offset = Vector2($Label.size.x / 2.0, $Label.size.y / 2.0)
	tween = create_tween()
	tween.set_loops()
	tween.tween_property($Label, "scale", Vector2(1.3, 1.3), 2)
	#tween.set_ease(Tween.EASE_IN_OUT) # Recommended for smooth pulsing
	tween.tween_property($Label, "scale", Vector2(1.0, 1.0), 2)
	#tween.set_ease(Tween.TRANS_LINEAR)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://selection.tscn")
	print("Start pressed")


func _on_settings_pressed() -> void:
	print("Settings pressed")
	main_buttons.visible = false
	options.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_options_pressed() -> void:
	_ready()

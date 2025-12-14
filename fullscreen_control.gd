extends CheckButton

func _ready() -> void:
	# sync ปุ่มตามค่าที่จำไว้
	button_pressed = Setting.fullscreen

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_toggled(toggled_on: bool) -> void:
	Setting.fullscreen = toggled_on
	Setting.apply_window_mode()

extends Node2D

@export var float_up_speed: float = 35.0
@export var fade_speed: float = 1.2
@export var lifetime: float = 0.8

var elapsed := 0.0
var label: Label

func _ready() -> void:
	label = $Label
	label.modulate.a = 1.0
	set_as_top_level(true)   # ← แก้ตรงนี้

func set_text(value: String, color := Color.RED) -> void:
	label.text = value
	label.modulate = color

func _process(delta: float) -> void:
	elapsed += delta

	position.y -= float_up_speed * delta
	label.modulate.a = 1.0 - (elapsed / lifetime)

	if elapsed >= lifetime:
		queue_free()

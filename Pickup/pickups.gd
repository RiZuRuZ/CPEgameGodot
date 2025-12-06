extends Area2D

var direction : Vector2
var speed : float = 175

@export var type : Pickups
@export var player_reference : CharacterBody2D:
	set(value):
		player_reference = value
		if type:
			type.player_reference = value

var can_follow : bool = false


func _ready() -> void:
	if type:
		$Sprite2D.texture = type.icon


func _physics_process(delta: float) -> void:
	if player_reference and can_follow:
		direction = (player_reference.position - position).normalized()
		position += direction * speed * delta


func follow(_target: CharacterBody2D) -> void:
	# ถ้าต้องการเก็บ target ก็ทำได้แบบนี้
	player_reference = _target
	can_follow = true


func _on_body_entered(body: Node2D) -> void:
	if type:
		type.activate()
	queue_free()

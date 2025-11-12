extends Node2D

const SPEED = 300
var animation
var sprite

func _ready() -> void:
	animation = $AnimationBocchi
	sprite = $Bocchi   # Make sure your Sprite2D node is named “Soldier”
	animation.play("Bocchi")

extends Control




@export var numberofplayer: int

var player = 10*numberofplayer
var tween :Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var Vboxandspritrlenght = 861.0-423.0
	$VBoxContainer2/soldier.pivot_offset = Vector2($VBoxContainer2/soldier.size.x/2,$VBoxContainer2/soldier.size.y/2)
	$VBoxContainer/swordman.pivot_offset = Vector2($VBoxContainer/swordman.size.x/2,$VBoxContainer/swordman.size.y/2)
	$VBoxContainer3/Axeman.pivot_offset = Vector2($VBoxContainer3/Axeman.size.x/2,$VBoxContainer3/Axeman.size.y/2)
	$VBoxContainer4/archer.pivot_offset = Vector2($VBoxContainer4/archer.size.x/2,$VBoxContainer4/archer.size.y/2)

	$VBoxContainer.position.x = $swordman.position.x-Vboxandspritrlenght
	$VBoxContainer2.position.x = $soldier.position.x-Vboxandspritrlenght
	$VBoxContainer3.position.x = $axeman.position.x-Vboxandspritrlenght
	$VBoxContainer4.position.x = $archer.position.x-Vboxandspritrlenght
	$Camera2D.position.x = $swordman.position.x-173
func _process(delta: float) -> void:
	$swordman/AnimationPlayer.play("idel")
	$soldier/AnimationPlayer.play("idel")
	$axeman/AnimationPlayer.play("idel")
	$archer/AnimationPlayer.play("idel")
	if player == 0:
		player = 10*numberofplayer
	if player%numberofplayer == 0 and $Camera2D.position.x != $swordman.position.x-173:
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($swordman.position.x-173,320),1)
	elif player%numberofplayer == 1 and $Camera2D.position.x != $soldier.position.x-173:
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($soldier.position.x-173,320),1)
	elif player%numberofplayer == 2 and $Camera2D.position.x != $axeman.position.x-173:
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($axeman.position.x-173,320),1)
	elif player%numberofplayer == 3 and $Camera2D.position.x != $archer.position.x-173:
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($archer.position.x-173,320),1)
func _on_next_butt_pressed() -> void:
	player += 1


func _on_prevbutt_pressed() -> void:
	player -=1

func _on_swordman_pressed() -> void:
	$"/root/Wave".selection = 1
	get_tree().change_scene_to_file("res://main.tscn")


func _on_soldier_pressed() -> void:
	$"/root/Wave".selection = 0
	get_tree().change_scene_to_file("res://main.tscn")


func _on_swordman_mouse_entered() -> void:
	$VBoxContainer/swordman.scale = Vector2(1.2,1.2)
	#$swordman.visible=true

func _on_soldier_mouse_entered() -> void:
	$VBoxContainer2/soldier.scale = Vector2(1.2,1.2)
	#$soldier.visible=true

func _on_soldier_mouse_exited() -> void:
	$VBoxContainer2/soldier.scale = Vector2(1,1)
	#$soldier.visible=false

func _on_swordman_mouse_exited() -> void:
	$VBoxContainer/swordman.scale = Vector2(1,1)
	#$swordman.visible=false


func _on_axeman_pressed() -> void:
	$"/root/Wave".selection = 2
	get_tree().change_scene_to_file("res://main.tscn")


func _on_archer_pressed() -> void:
	$"/root/Wave".selection = 3
	get_tree().change_scene_to_file("res://main.tscn")

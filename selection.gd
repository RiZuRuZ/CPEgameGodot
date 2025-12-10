extends Control




@export var numberofplayer: int

var player = 10*numberofplayer
var tween :Tween
@export var scroll_time:int
var skill =0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	numberofplayer = get_tree().get_node_count_in_group("player")
	player = 10*numberofplayer
	var Vboxandspritrlenght = 861.0-440.0
	$VBoxContainer2/soldier.pivot_offset = Vector2($VBoxContainer2/soldier.size.x/2,$VBoxContainer2/soldier.size.y/2)
	$VBoxContainer/swordman.pivot_offset = Vector2($VBoxContainer/swordman.size.x/2,$VBoxContainer/swordman.size.y/2)
	$VBoxContainer3/Axeman.pivot_offset = Vector2($VBoxContainer3/Axeman.size.x/2,$VBoxContainer3/Axeman.size.y/2)
	$VBoxContainer4/archer.pivot_offset = Vector2($VBoxContainer4/archer.size.x/2,$VBoxContainer4/archer.size.y/2)
	$VBoxContainer5/wizard.pivot_offset = Vector2($VBoxContainer5/wizard.size.x/2,$VBoxContainer5/wizard.size.y/2)
	$VBoxContainer.position.x = $swordman.position.x-Vboxandspritrlenght
	$VBoxContainer2.position.x = $soldier.position.x-Vboxandspritrlenght
	$VBoxContainer3.position.x = $axeman.position.x-Vboxandspritrlenght
	$VBoxContainer4.position.x = $archer.position.x-Vboxandspritrlenght
	$VBoxContainer5.position.x = $wizard.position.x-Vboxandspritrlenght
	$Camera2D.position.x = $swordman.position.x-100
func _process(delta: float) -> void:
	print(skill)
	if skill ==0 :
		$swordman/AnimatedSprite2D.play("idle")
		$soldier/AnimatedSprite2D.play("idle")
		$axeman/AnimatedSprite2D.play("idle")
		$archer/AnimatedSprite2D.play("idle")
		$wizard/AnimatedSprite2D.play("idle")
	elif skill == 1:
		pass
		$swordman/AnimatedSprite2D.play("attack1")
		$soldier/AnimatedSprite2D.play("attack1")
		$axeman/AnimatedSprite2D.play("attack1")
		$archer/AnimatedSprite2D.play("attack1")
		$wizard/AnimatedSprite2D.play("attack1")
	elif skill == 2:
		pass
		$swordman/AnimatedSprite2D.play("attack2")
		$soldier/AnimatedSprite2D.play("attack2")
		$axeman/AnimatedSprite2D.play("attack2")
		$archer/AnimatedSprite2D.play("attack2")
	elif skill == 3:
		pass
		$swordman/AnimatedSprite2D.play("attack3")
		$soldier/AnimatedSprite2D.play("attack3")
		$axeman/AnimatedSprite2D.play("attack3")

	if player == 0:
		player = 10*numberofplayer
	if player%numberofplayer == 0 and $Camera2D.position.x != $swordman.position.x-100:
		
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($swordman.position.x-100,320),scroll_time)
		$CanvasLayer2/hero.text = "Swordman"
	elif player%numberofplayer == 1 and $Camera2D.position.x != $soldier.position.x-100:
		
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($soldier.position.x-100,320),scroll_time)
		$CanvasLayer2/hero.text = "Soldier"
	elif player%numberofplayer == 2 and $Camera2D.position.x != $axeman.position.x-100:
		
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($axeman.position.x-100,320),scroll_time)
		$CanvasLayer2/hero.text = "Axeman"
	elif player%numberofplayer == 3 and $Camera2D.position.x != $archer.position.x-100:
		
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($archer.position.x-100,320),scroll_time)
		$CanvasLayer2/hero.text = "Archer"
	elif player%numberofplayer == 4 and $Camera2D.position.x != $wizard.position.x-100:
		
		tween = create_tween()
		tween.tween_property($Camera2D,"position", Vector2($wizard.position.x-100,320),scroll_time)
		$CanvasLayer2/hero.text = "Wizard"
func _on_next_butt_pressed() -> void:
	player += 1


func _on_prevbutt_pressed() -> void:
	player -=1

func _on_swordman_pressed() -> void:
	$"/root/Wave".selection = 1
	get_tree().change_scene_to_file("res://Ascenes/cutscene/cut_scene_intro.tscn")


func _on_soldier_pressed() -> void:
	$"/root/Wave".selection = 0
	get_tree().change_scene_to_file("res://Ascenes/cutscene/cut_scene_intro.tscn")


func _on_axeman_pressed() -> void:
	$"/root/Wave".selection = 2
	get_tree().change_scene_to_file("res://Ascenes/cutscene/cut_scene_intro.tscn")


func _on_archer_pressed() -> void:
	$"/root/Wave".selection = 3
	get_tree().change_scene_to_file("res://Ascenes/cutscene/cut_scene_intro.tscn")


func _on_wizard_pressed() -> void:
	$"/root/Wave".selection = 4
	get_tree().change_scene_to_file("res://Ascenes/cutscene/cut_scene_intro.tscn")


func _on_wizard_mouse_entered() -> void:
	$VBoxContainer5/wizard.scale = Vector2(1.2,1.2)


func _on_wizard_mouse_exited() -> void:
	$VBoxContainer5/wizard.scale = Vector2(1,1)


func _on_archer_mouse_entered() -> void:
	$VBoxContainer4/archer.scale = Vector2(1.2,1.2)


func _on_archer_mouse_exited() -> void:
	$VBoxContainer4/archer.scale = Vector2(1,1)


func _on_axeman_mouse_entered() -> void:
	$VBoxContainer3/Axeman.scale = Vector2(1.2,1.2)


func _on_axeman_mouse_exited() -> void:
	$VBoxContainer3/Axeman.scale = Vector2(1,1)
	
func _on_swordman_mouse_entered() -> void:
	$VBoxContainer/swordman.scale = Vector2(1.2,1.2)
	#$swordman.visible=true
	
func _on_soldier_mouse_exited() -> void:
	$VBoxContainer2/soldier.scale = Vector2(1,1)
	#$soldier.visible=false


func _on_soldier_mouse_entered() -> void:
	$VBoxContainer2/soldier.scale = Vector2(1.2,1.2)
	#$soldier.visible=true


func _on_swordman_mouse_exited() -> void:
	$VBoxContainer/swordman.scale = Vector2(1,1)
	#$swordman.visible=false


func _on_m_1_mouse_entered() -> void:
	skill= 1
	print(skill)


func _on_m_1_mouse_exited() -> void:
	skill= 0


func _on_m_2_mouse_entered() -> void:
	skill= 2


func _on_m_2_mouse_exited() -> void:
	skill= 0


func _on_q_mouse_entered() -> void:
	skill= 3


func _on_q_mouse_exited() -> void:
	skill= 0


func _on_button_mouse_entered() -> void:
	pass # Replace with function body.


func _on_button_mouse_exited() -> void:
	pass # Replace with function body.

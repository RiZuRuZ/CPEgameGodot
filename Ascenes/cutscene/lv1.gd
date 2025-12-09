extends Node2D

@onready var name_label = $UI/Panel/VBoxContainer/Label
@onready var dialogue_text = $UI/Panel/VBoxContainer/RichTextLabel

# --- DIALOGUES ---
var dialogues = [
	{"name": "DEMON LORD", "char": "DEMON_LORD", "text": "ยังดื้ออยู่อีกเหรอ... เจ้าหญิงของอาณาจักรมนุษย์"},
	{"name": "PRINCESS", "char": "PRINCESS", "text": "ฉันไม่มีอะไรจะพูดกับเจ้า"},
	{"name": "DEMON LORD", "char": "DEMON_LORD", "text": "โอ้? แต่ข้าเพิ่งเห็นเจ้าตัวสั่นเมื่อกี้นี่นา… กลัวงั้นเหรอ?"},
	{"name": "PRINCESS", "char": "PRINCESS", "text": "ฉันไม่เคยกลัวสัตว์ประหลาดอย่างเจ้า"},
	{"name": "DEMON LORD", "char": "DEMON_LORD", "text": "ดี… ความกล้าของเจ้านี่แหละที่ข้าชอบ"},
	{"name": "DEMON LORD", "char": "DEMON_LORD", "text": "แต่เจ้าคงไม่รู้สินะว่าทหารของเจ้ากำลังถูกกำจัดทีละคนในป่า…"},
	{"name": "PRINCESS", "char": "PRINCESS", "text": "ไม่นะ…! พวกเขา—!"},
	{"name": "DEMON LORD", "char": "DEMON_LORD", "text": "อย่าเพิ่งร้องไห้สิ เจ้าหญิง… นี่เพิ่งเริ่มต้นเท่านั้น"},
	{"name": "DEMON LORD", "char": "DEMON_LORD", "text": "อีกไม่นาน… มนุษย์ที่ชื่อ 'ผู้เล่น' นั่น ก็จะมาถึงที่นี่…"},
	{"name": "PRINCESS", "char": "PRINCESS", "text": "หยุดยุ่งกับเขานะ!!"},
	{"name": "DEMON LORD", "char": "DEMON_LORD", "text": "หึ… หรือเจ้าแค่ไม่อยากให้เขาเห็นสภาพอ่อนแอของเจ้าตอนนี้?"},
	{"name": "PRINCESS", "char": "PRINCESS", "text": "…"},
	{"name": "DEMON LORD", "char": "DEMON_LORD", "text": "จงรออย่างสิ้นหวังอยู่ที่นี่ไปเถอะ เจ้าหญิง… ข้าจะกลับมาเมื่อถึงเวลา"},
]

var current_index = 0
var typing_speed = 0.03
var is_typing = false
var full_text = ""
var displayed_text = ""

func _ready():
	show_dialogue()

func show_character(name: String):
	for c in $character.get_children():
		c.visible = (c.name == name)

func show_dialogue():
	var data = dialogues[current_index]
	name_label.text = data.name
	show_character(data.char)

	full_text = data.text
	displayed_text = ""
	dialogue_text.text = ""
	is_typing = true
	type_text()

func type_text():
	for c in full_text:
		if not is_typing:
			break
		displayed_text += c
		dialogue_text.text = displayed_text
		await get_tree().create_timer(typing_speed).timeout

	is_typing = false
	dialogue_text.text = full_text

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			is_typing = false
			dialogue_text.text = full_text
		else:
			current_index += 1

			if current_index < dialogues.size():
				show_dialogue()
			else:
				cutscene_end()

func cutscene_end():
	# หลังจบ cutscene จะกลับไปเกมผู้เล่นที่ป่า
	get_tree().change_scene_to_file("res://Scenes/stage1_continue.tscn")

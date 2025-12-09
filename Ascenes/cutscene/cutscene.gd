extends Node2D

@onready var name_label = $UI/Panel/VBoxContainer/Label
@onready var dialogue_text = $UI/Panel/VBoxContainer/RichTextLabel

var dialogues = [
	{"name": "PRINCESS", "text": "SOS!!!", "char": "PRINCESS"},
	{"name": "DEMON", "text": "ฮิฮิ เจ้าหญิง… คิดว่าจะหนีฉันพ้นเหรอ~", "char": "DEMON"},
	{"name": "PRINCESS", "text": "ปล่อยฉันไปนะ!!", "char": "PRINCESS"},
]

var current_index = 0
var typing_speed = 0.03
var is_typing = false
var full_text = ""
var displayed_text = ""

func _ready():
	show_dialogue()

# 🔥 ฟังก์ชันสลับตัวละคร
func show_character(name: String):
	var chars = $character.get_children()
	for c in chars:
		c.visible = (c.name == name)

func show_dialogue():
	var data = dialogues[current_index]
	name_label.text = data.name

	# 🔥 เปิดเฉพาะตัวที่พูด
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
				print("Cutscene จบแล้ว")

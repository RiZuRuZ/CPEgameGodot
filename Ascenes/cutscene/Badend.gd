extends Node2D

@onready var name_label = $UI/Panel/VBoxContainer/Label
@onready var dialogue_text = $UI/Panel/VBoxContainer/RichTextLabel
@onready var ending_image = $EndingImage   # TextureRect

# ---------------- BAD END DIALOGUES ----------------
var dialogues = [
	{
		"name": "HERO",
		"text": "แฮ่ก… ข้า… ยังไม่พออีกเหรอ…",
		"char": "HERO"
	},
	{
		"name": "DEMON",
		"text": "พอแค่นี้เถอะ ผู้กล้า… เจ้าไปไกลที่สุดแล้ว",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "หยุดเถอะ… ได้โปรด…",
		"char": "PRINCESS"
	},
	{
		"name": "HERO",
		"text": "เจ้าหญิง… หนีไป… อย่าอยู่ที่นี่…",
		"char": "HERO"
	},
	{
		"name": "PRINCESS",
		"text": "ไม่… ข้าจะไม่หนีอีกแล้ว",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "เจ้าตัดสินใจแล้วสินะ… เจ้าหญิง",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "ข้าเหนื่อยกับการรอให้ใครมาช่วย…\nจอมมาร… ข้าขออยู่ข้างเจ้า",
		"char": "PRINCESS"
	},
	{
		"name": "HERO",
		"text": "เจ้า… เลือกเขางั้นเหรอ…?",
		"char": "HERO"
	},
	{
		"name": "PRINCESS",
		"text": "ขอโทษนะ ผู้กล้า… นี่คือการตัดสินใจของข้า",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "ไม่ต้องกลัวอีกต่อไป… ข้าจะปกป้องเจ้าเอง",
		"char": "DEMON"
	},
	{
		"name": "SYSTEM",
		"text": "ผู้กล้าพ่ายแพ้\nโลกเข้าสู่เงาของจอมมาร\nแต่เจ้าหญิง… ได้เลือกชะตาของตนเองแล้ว",
		"char": ""
	}
]


var current_index = 0
var typing_speed = 0.03
var is_typing = false
var full_text = ""
var displayed_text = ""
var ending_shown = false

func _ready():
	ending_image.visible = false
	show_dialogue()

# -------- SWITCH CHARACTER SPRITE --------
func show_character(name: String):
	for c in $character.get_children():
		c.visible = (c.name == name)

# -------- SHOW DIALOGUE --------
func show_dialogue():
	var data = dialogues[current_index]
	name_label.text = data.name
	show_character(data.char)

	full_text = data.text
	displayed_text = ""
	dialogue_text.text = ""

	is_typing = true
	type_text()

# -------- TYPEWRITER EFFECT --------
func type_text():
	for c in full_text:
		if not is_typing:
			break
		displayed_text += c
		dialogue_text.text = displayed_text
		await get_tree().create_timer(typing_speed).timeout

	is_typing = false
	dialogue_text.text = full_text

# -------- INPUT --------
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			is_typing = false
			dialogue_text.text = full_text
			return

		if not ending_shown:
			current_index += 1
			if current_index < dialogues.size():
				show_dialogue()
			else:
				show_ending_image()
		else:
			back_to_menu()

# -------- SHOW ENDING IMAGE --------
func show_ending_image():
	ending_shown = true
	$UI.visible = false
	ending_image.visible = true

# -------- BACK TO MENU --------
func back_to_menu():
	get_tree().change_scene_to_file("res://main_menu_fixed.tscn")

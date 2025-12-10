extends Node2D

@onready var name_label = $UI/Panel/VBoxContainer/Label
@onready var dialogue_text = $UI/Panel/VBoxContainer/RichTextLabel

# --- DIALOGUES (Updated with NEW SCRIPT) ---
var dialogues = [
	{
		"name": "PRINCESS",
		"text": "ทำไม… ถึงเงียบแบบนี้นะ… ไม่เห็นแม้แต่เงาของปีศาจสักตัว…",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "เจ้ากลัวความเงียบรึ เจ้าหญิง? หรือกลัว… ตัวเองมากกว่า?",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "ฉันไม่กลัวเจ้า! ต่อให้ขังฉันไว้ที่นี่ ฉันก็จะหาทางหนีจนได้!",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "หึหึ… เจ้าพยายามหนีมาตลอด แต่รู้ไหมว่าทุกย่างก้าวของเจ้า—ข้าเห็นหมดทุกอย่าง",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "ถ้าอยากจะทำอะไรก็ทำสิ! แต่หยุดทำตัวน่ารำคาญแบบนี้สักที!",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "น่ารำคาญ? ข้าคิดว่าเจ้าต่างหาก… ที่ทำให้ข้าสนใจมากขึ้นทุกที",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "อะไรของเจ้า!? อย่ามาเล่นลิ้นนะ!!",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "เพราะเจ้า… ทำหน้าตาน่าสนุกเวลาที่โกรธแบบนี้ไงล่ะ",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "……! (ใจเย็นไว้… ฉันต้องไม่ถูกมันปั่น…) ",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "พักผ่อนซะ เจ้าหญิง… ก่อนที่ฮีโร่ของเจ้าจะเดินมาถึงที่นี่…",
		"char": "DEMON"
	},
	{
		"name": "DEMON",
		"text": "และพบว่าทุกอย่าง… มันสายไปแล้ว",
		"char": "DEMON"
	}
]

var current_index = 0
var typing_speed = 0.03
var is_typing = false
var full_text = ""
var displayed_text = ""

func _ready():
	show_dialogue()
	$"/root/Wave/CanvasLayer".visible = false
# ------ SWITCH CHARACTER SPRITE ------
func show_character(name: String):
	for c in $character.get_children():
		c.visible = (c.name == name)

# ------ DISPLAY DIALOGUE ------
func show_dialogue():
	var data = dialogues[current_index]
	name_label.text = data.name
	show_character(data.char)

	full_text = data.text
	displayed_text = ""
	dialogue_text.text = ""
	is_typing = true
	type_text()

# ------ TYPEWRITER EFFECT ------
func type_text():
	for c in full_text:
		if not is_typing:
			break
		displayed_text += c
		dialogue_text.text = displayed_text
		await get_tree().create_timer(typing_speed).timeout

	is_typing = false
	dialogue_text.text = full_text

# ------ INPUT ------
func _input(event):
	if event.is_action_pressed("ui_accept"):
		# Skip typing
		if is_typing:
			is_typing = false
			dialogue_text.text = full_text
			return

		# Next dialogue
		current_index += 1
		if current_index < dialogues.size():
			show_dialogue()
		else:
			cutscene_end()

# ------ END CUTSCENE ------
func cutscene_end():
	# กลับไปด่านผู้เล่น
	get_tree().change_scene_to_file("res://Stage/stage3.tscn")

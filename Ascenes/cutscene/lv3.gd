extends Node2D

@onready var name_label = $UI/Panel/VBoxContainer/Label
@onready var dialogue_text = $UI/Panel/VBoxContainer/RichTextLabel

# --- DIALOGUES (Level 3 Ending) ---
var dialogues = [
	{
		"name": "PRINCESS",
		"text": "วันนี้… ทำไมเจ้าถึงกลับมาเร็วนักล่ะ? ข้าไม่ได้เป็นห่วงหรอกนะ… แค่ถามเฉยๆ",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "เจ้าห่วงข้าแน่นอนล่ะ ถึงแม้เจ้าจะปากแข็งก็ตาม",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "ขะ…ใครจะไปห่วงเจ้า! ข้าแค่… ไม่อยากให้คนที่จับข้ามาตายไปเฉยๆก็เท่านั้น!",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "พูดแบบนั้นทุกวัน ข้าชักจะแยกไม่ออกแล้วว่าเจ้าปากแข็ง… หรือจริงๆแล้วกำลังกังวล",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "เจ้าอย่าเข้าใจผิดนักสิ!",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "แต่วันนี้เจ้ามองข้าบ่อยผิดปกตินะ… หรือว่ามีอะไรอยากบอก?",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "ข…ข้าแค่สงสัยว่า… ทำไมเจ้าถึงไม่ทำร้ายข้าเลยสักครั้ง ทั้งที่ข้าคือเชลย",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "ข้าไม่มีวันทำร้ายเจ้า เจ้าหญิง",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "เจ้า… เปลี่ยนไปมากจากตอนแรกที่จับข้ามา",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "หรือบางที… ข้าอาจจะเป็นแบบนี้มาตลอด แต่เพิ่งมีใครบางคนทำให้ข้าอยากแสดงออก",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "…….",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "กลัวข้าหรือไม่?",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "ข้า… ไม่รู้สิ แต่เวลาที่อยู่กับเจ้า… ข้าไม่กลัวเหมือนเมื่อก่อนแล้ว",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "เจ้าพูดแบบนี้… ข้าก็เริ่มคิดจริงๆแล้วว่าเจ้าอาจจะใจอ่อนกับข้า",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "ม…ไม่จริง! ข้าแค่… ชินแล้วก็เท่านั้น!",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "ชินกับข้า… งั้นหรือ?",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "เจ้าอย่ามายิ้มแบบนั้นนะ!",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "เจ้าหญิง… ข้าไม่รู้ว่าทำไม แต่ทุกครั้งที่คุยกับเจ้า ข้ารู้สึกว่า… ข้าไม่อยากให้สงครามนี้จบแบบเดิมอีกต่อไป",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "…… เจ้ากำลังพูดเรื่องอะไรน่ะ?",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "บางที… เราสองคนอาจไม่จำเป็นต้องเป็นศัตรูกันก็ได้",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "หยุดพูดนะ! ถ้าเจ้าพูดแบบนั้นอีก… ข้าอาจจะ…",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "อาจจะอะไรล่ะ… เจ้าหญิง?",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "ข้าอาจจะ… เชื่อเจ้าก็ได้",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "งั้นก็ลองเชื่อข้าดูสิ",
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
		if is_typing:
			is_typing = false
			dialogue_text.text = full_text
			return

		current_index += 1
		if current_index < dialogues.size():
			show_dialogue()
		else:
			cutscene_end()

# ------ END CUTSCENE ------
func cutscene_end():
	get_tree().change_scene_to_file("res://Stage/stage4.tscn")

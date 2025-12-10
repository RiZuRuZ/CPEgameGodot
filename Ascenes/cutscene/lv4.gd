extends Node2D

@onready var name_label = $UI/Panel/VBoxContainer/Label
@onready var dialogue_text = $UI/Panel/VBoxContainer/RichTextLabel

# --- DIALOGUES (FINAL ENDING SCENE) ---
var dialogues = [
	{
		"name": "DEMON",
		"text": "เจ้ามาช้าไปแล้ว… ผู้กล้า",
		"char": "DEMON"
	},
	{
		"name": "HERO",
		"text": "ปล่อยเจ้าหญิงเดี๋ยวนี้! ฉันจะไม่ให้เจ้าทำร้ายเธออีกต่อไป!",
		"char": "HERO"
	},
	{
		"name": "PRINCESS",
		"text": "ผู้กล้า… เจ้ามาแล้วจริงๆ…",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "หึ… เจ้าหญิงของเจ้าไม่เคยบอกเจ้าหรอกหรือ? ว่านาง… ไม่ได้เกลียดข้าอย่างที่เจ้าคิด",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "ขะ…ข้าไม่ได้พูดแบบนั้น! เจ้าอย่าบิดเบือนคำของข้า!",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "แต่นางก็ไม่ได้ปฏิเสธ… ใช่ไหมล่ะ?",
		"char": "DEMON"
	},
	{
		"name": "HERO",
		"text": "ฉันจะไม่ยอมให้เธออยู่กับคนแบบเจ้าเด็ดขาด!",
		"char": "HERO"
	},
	{
		"name": "DEMON",
		"text": "งั้นก็พิสูจน์ความสามารถของเจ้าให้ข้าดู… ผู้กล้า!\n(ดึงเจ้าหญิงมากอด)",
		"char": "DEMON"
	},
		{
		"name": "HERO",
		"text": "แกทำร้ายเจ้าหญิงฉันหร๋อ!!👊🏻💢👣👊🏻👣💢👊🏻\n(เตะจอมมาร)",
		"char": "HERO"
	},
	# ---- หลังต่อสู้ ผู้เล่นชนะ ----
	{
		"name": "DEMON",
		"text": "ข้า… แพ้แล้ว… สุดท้ายชะตาก็เลือกเจ้าอีกครั้ง…",
		"char": "DEMON"
	},
	{
		"name": "PRINCESS",
		"text": "เจ้า… จอมมาร… ข้า…",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "ไม่ต้องพูดอะไร เจ้าหญิง… เพียงแค่เจ้าปลอดภัย… ข้าก็พอใจแล้ว",
		"char": "DEMON"
	},
	{
		"name": "HERO",
		"text": "เจ้าหญิง ไปกันเถอะ ฉันจะพาเธอกลับบ้าน",
		"char": "HERO"
	},
	{
		"name": "PRINCESS",
		"text": "อื้ม… แล้วก็… ขอบคุณนะ ผู้กล้า",
		"char": "PRINCESS"
	},
	{
		"name": "DEMON",
		"text": "ลาก่อน… เจ้าหญิงของข้า",
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
	get_tree().change_scene_to_file("res://main_menu_fixed.tscn")

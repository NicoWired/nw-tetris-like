class_name SettingsIcon
extends TextureRect

signal settings_clicked

var button_cd: bool = false
@onready var cd_timer: Timer = Timer.new()

func _ready() -> void:
	cd_timer.one_shot = true
	cd_timer.autostart = false
	cd_timer.wait_time = 0.5
	cd_timer.timeout.connect(func(): button_cd = false)
	add_child(cd_timer)

func _gui_input(_event: InputEvent) -> void:
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
	if Input.is_action_just_pressed("left_click") and not button_cd:
		button_cd = true
		cd_timer.start()
		print("pressed")
		settings_clicked.emit()

class_name ActionInput
extends HBoxContainer

signal keybind_ongoing

const ACTION_NAMES: Dictionary = {
	"rotate_clockwise": "Rotate right"
	, "rotate_counterclockwise": "Rotate left"
	, "move_left": "Left"
	, "move_right": "Right"
	, "drop_piece": "Soft drop"
	, "hold_piece": "Hold"
	, "hard_drop": "Hard drop"
	, "start": "Start"
}

@export var action_name: String
var waiting_for_key: bool = false
var action_event: String
@onready var linedit: LineEdit = $LineEdit

func _ready() -> void:
	set_labels()
	$LineEdit.connect("gui_input", Callable(self, "_on_textedit_gui_input"))

func _on_textedit_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		waiting_for_key = true
		$LineEdit.text = "Press a key..."
		get_viewport().set_input_as_handled()
		keybind_ongoing.emit(waiting_for_key)

func _unhandled_input(event):
	if waiting_for_key and event is InputEventKey and event.pressed:
		waiting_for_key = false
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, event)
		$LineEdit.text = event.as_text()
		get_viewport().set_input_as_handled()
		keybind_ongoing.emit(waiting_for_key)

func trim_action_name(input_name: String) -> String:
	var parenthesis_pos: int = input_name.find("(")
	if parenthesis_pos > 0:
		input_name = input_name.substr(0,parenthesis_pos-1)
	return input_name

func set_labels() -> void:
	action_event = InputMap.action_get_events(action_name)[0].as_text()
	action_event = trim_action_name(action_event)
	$Label.text = ACTION_NAMES[action_name]
	$LineEdit.text = action_event

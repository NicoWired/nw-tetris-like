extends Node

const INPUTMAP_SAVE_PATH: String = "user://settings.json"

var inputs_to_save: Array[StringName] = [
	"rotate_clockwise"
	, "rotate_counterclockwise"
	, "move_left"
	, "move_right"
	, "drop_piece"
	, "hold_piece"
	, "hard_drop"
	, "start"
	]

func save_inputmap_to_file() -> void:
	var data: Dictionary = {}
	for action: StringName in inputs_to_save:
		var key_bindings: Array = []
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				key_bindings.append({
					"keycode": event.keycode,
					"physical_keycode": event.physical_keycode if event.physical_keycode != 0 else null
				})
		data[action] = key_bindings
	var file: FileAccess = FileAccess.open(INPUTMAP_SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func load_inputmap_from_file() -> void:
	if not FileAccess.file_exists(INPUTMAP_SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(INPUTMAP_SAVE_PATH, FileAccess.READ)
	var text: String = file.get_as_text()
	file.close()
	var result = JSON.parse_string(text)
	if typeof(result) != TYPE_DICTIONARY:
		return
	for action: StringName in inputs_to_save:
		if action in result:
			InputMap.action_erase_events(action)
			for key_data in result[action]:
				var event: InputEventKey = InputEventKey.new()
				event.keycode = key_data["keycode"]
				if key_data["physical_keycode"] != null:
					event.physical_keycode = key_data["physical_keycode"]
				InputMap.action_add_event(action, event)

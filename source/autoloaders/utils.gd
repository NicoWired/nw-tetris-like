extends Node

func get_start_key_name() -> String:
	var full_name: String = InputMap.action_get_events("start")[0].as_text()
	var spaces: int = full_name.find(" ")
	if spaces == -1:
		return full_name
	return full_name.substr(0,spaces)

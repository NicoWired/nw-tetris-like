extends GridContainer

func cancel_keybdinig() -> void:
	for child: ActionInput in get_children():
		child.waiting_for_key = false
		child.set_labels()

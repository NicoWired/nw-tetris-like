class_name Settings
extends Control

signal ready_to_close

func _ready() -> void:
	%Cancel.button_down.connect(on_cancel_pressed)
	%Accept.button_down.connect(on_accept_pressed)
	
func on_cancel_pressed() -> void:
	%KeybindsMenu.cancel_keybdinig()
	close_settings()

func on_accept_pressed() -> void:
	LoadSaveSettings.save_inputmap_to_file()
	close_settings()

func close_settings() -> void:
	ready_to_close.emit()

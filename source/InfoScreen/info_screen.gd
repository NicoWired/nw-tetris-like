class_name InfoScreen
extends CenterContainer

var start_key: String

@onready var label: Label = $PanelContainer/Label


func _ready() -> void:
	start_key = Utils.get_start_key_name()
	label.text = 'Press %s to start.' % start_key

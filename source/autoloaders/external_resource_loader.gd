extends Node

var sprites: Dictionary
var pieces: Array[String] = ["i", "j", "l", "o", "s", "t", "z"]

func _enter_tree() -> void:
	for piece: String in pieces:
		sprites[piece] = {
			"square": load("res://assets/sprites/pieces/square_%s.png" % piece)
			, "thumbnail": load("res://assets/sprites/pieces/thumbnail_%s.png" % piece)
		}

class_name ShapeGeneric
extends Node

var tetrominoe_matrix: Array[Dictionary]
var tetrominoe_texture: Texture2D
var x_offset: int
var thumbnail: Texture2D

func _init() -> void:
	assert(tetrominoe_matrix and tetrominoe_texture and x_offset and thumbnail, "shape resource not properly initialized")

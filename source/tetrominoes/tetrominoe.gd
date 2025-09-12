class_name tetrominoe
extends Node2D

signal piece_moved

var tile_size: int
var tetrominoe_matrix: Array[Dictionary]
var current_position: int = 0
var tetrominoe_data: ShapeGeneric
var initialized: bool = false
var tetrominoe_coords: Array[Vector2i]
var board_position: Vector2i
var squares: Array[Sprite2D]

func initialize(
	input_tetrominoe_shape: ShapeGeneric,
	input_tile_size: int,
	input_board_positon: Vector2i = Vector2i(0,0)) -> void:

	tile_size = input_tile_size
	tetrominoe_data = input_tetrominoe_shape
	tetrominoe_matrix = tetrominoe_data.tetrominoe_matrix
	board_position = input_board_positon
	tetrominoe_coords = tetrominoe_matrix[current_position].values()[0]
	initialized = true

func _ready() -> void:
	assert(initialized, "Please initialize the tetrominoe")
	create_tetrominoe(tetrominoe_coords)

func create_tetrominoe(coordinates: Array[Vector2i]) -> void:
	for coord in coordinates:
		var square_sprite: Sprite2D = Sprite2D.new()
		square_sprite.texture = tetrominoe_data.tetrominoe_texture
		square_sprite.centered = false
		square_sprite.position = (coord+board_position) * tile_size 
		squares.append(square_sprite)
		add_child(square_sprite)

func rotate_tetrominoe(new_coords: Array[Vector2i], direction: int) -> void:
	assert(direction in [-1,1], "direction can only be 1 or -1")
	
	var new_direction: int = calculate_new_rotation_direction(direction)
	current_position = new_direction
	
	var i = 0
	for square: Sprite2D in squares:
		square.position = new_coords[i] * tile_size
		i += 1
	
	piece_moved.emit()

func get_rotation_coords(direction: int) -> Array[Vector2i]:
	assert(direction in [-1,1], "direction can only be 1 or -1")
	var new_direction: int = calculate_new_rotation_direction(direction)
	var new_shape: Array[Vector2i] = tetrominoe_matrix[new_direction].values()[0]
	var new_coords: Array[Vector2i]
	for coord: Vector2i in new_shape:
		new_coords.append(coord + board_position)
	return new_coords
	
func move_tetrominoe(new_coords: Array[Vector2i], direction: Vector2i) -> void:
	board_position += direction
	var i: int = 0
	for square: Sprite2D in squares:
		square.position = new_coords[i] * tile_size
		i += 1
	piece_moved.emit()

func get_move_coords(direction: Vector2i) -> Array[Vector2i]:
	assert(direction.x in [-1,0,1], "direction.x can only be 1 or -1")
	var new_coords: Array[Vector2i]
	for square: Sprite2D in squares:
		new_coords.append(Vector2i(square.position / tile_size) + direction)
	return new_coords

func calculate_new_rotation_direction(direction: int) -> int:
	var new_direction: int = current_position + direction
	if new_direction == -1:
		new_direction = len(tetrominoe_matrix)-1
	elif new_direction == len(tetrominoe_matrix):
		new_direction = 0
	return new_direction

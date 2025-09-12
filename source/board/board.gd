class_name Board
extends Node2D

signal lines_cleared
signal game_over
signal piece_held
signal piece_spawned

const TILE_Y_OFFSET: int = -3
const DIRECTION_DOWN: Vector2i = Vector2i(0,1)
const DIRECTION_LEFT: Vector2i = Vector2i(-1,0)
const DIRECTION_RIGHT: Vector2i = Vector2i(1,0)
const MOVE_REPEAT_DELAY: float = 0.15
const MOVE_REPEAT_RATE: float = 0.05
const PIECES_IN_QUEUE: int = 2

var piece_types: Array = [
	ShapeI,
	ShapeJ,
	ShapeL,
	ShapeO,
	ShapeS,
	ShapeT,
	ShapeZ,
]
var current_piece: tetrominoe
var held_piece: ShapeGeneric
var hold_cd: bool = false
var board_state: Dictionary
var gravity_cd: float
var remaining_gravity_cd: float
var gravity_multiplier: float
var initialized: bool = false
var tile_size: int
var board_size: Vector2i
var ghost_squares: Array[Sprite2D] = []
var das_cd: float = MOVE_REPEAT_DELAY
var next_pieces: Array[ShapeGeneric]

func _ready() -> void:
	assert(initialized, "Please initialize the board")
	create_ghost_squares()

func _process(delta: float) -> void:
	if current_piece:
		# hold current piece
		if Input.is_action_just_pressed("hold_piece"):
			hold_piece()
		
		# send piece to the bottom
		if Input.is_action_just_pressed("hard_drop"):
			hard_drop()
		
		# check for rotation input
		if Input.is_action_just_pressed("rotate_clockwise"):
			try_to_rotate(1)
		elif Input.is_action_just_pressed("rotate_counterclockwise"):
			try_to_rotate(-1)
			
		# check for movement input
		if Input.is_action_just_pressed("move_left"):
			try_to_move(DIRECTION_LEFT)
		elif Input.is_action_pressed(("move_left")):
			das_cd -= delta
			if das_cd <= 0:
				try_to_move(DIRECTION_LEFT)
				das_cd = MOVE_REPEAT_RATE

		if Input.is_action_just_pressed("move_right"):
			try_to_move(DIRECTION_RIGHT)
		elif Input.is_action_pressed(("move_right")):
			das_cd -= delta
			if das_cd <= 0:
				try_to_move(DIRECTION_RIGHT)
				das_cd = MOVE_REPEAT_RATE

		if Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
			das_cd = MOVE_REPEAT_DELAY
		
		# check for soft drop input
		if Input.is_action_pressed("drop_piece"):
			gravity_multiplier = 3
		else:
			gravity_multiplier = 1
		
		# apply gravity
		remaining_gravity_cd -= delta * gravity_multiplier
		if remaining_gravity_cd <= 0:
			remaining_gravity_cd = gravity_cd
			var new_coords: Array[Vector2i] = current_piece.get_move_coords(DIRECTION_DOWN)
			if check_valid_cooords(new_coords):
				current_piece.move_tetrominoe(new_coords, DIRECTION_DOWN)
			else:
				bottom_reached()

func initialize_board(init_board_size: Vector2i,
		init_tile_size: int,
		init_gravity_cd: float) -> void:
	tile_size = init_tile_size
	board_size = init_board_size
	gravity_cd = init_gravity_cd
	remaining_gravity_cd = init_gravity_cd
	for i in range(PIECES_IN_QUEUE):
		next_pieces.append(await piece_types.pick_random().new())
	for x in range(board_size.x):
		for y in range(board_size.y):
			board_state[Vector2i(x,y)] = null
	initialized = true
	
	# delete any existing pieces
	if current_piece:
		current_piece.queue_free()
	
	# make ghost piece invisible
	for square: Sprite2D in ghost_squares:
		square.visible = false
	
	remaining_gravity_cd = gravity_cd

func create_ghost_squares() -> void:
	for i in range(4):
		var ghost_square = Sprite2D.new()
		ghost_square.visible = false
		ghost_square.modulate = Color(1,1,1,0.5)
		ghost_squares.append(ghost_square)
		add_child(ghost_square)

func update_ghost_squares() -> void:
	var ghost_coords: Array[Vector2i] = find_bottom()
	for i in range(4):
		ghost_squares[i].texture = current_piece.squares[i].texture
		ghost_squares[i].position = ghost_coords[i] * tile_size
		ghost_squares[i].centered = false
		ghost_squares[i].visible = true

func hold_piece() -> void:
	if not hold_cd:
		if held_piece is ShapeGeneric:
			var temp_piece:ShapeGeneric = held_piece
			held_piece = current_piece.tetrominoe_data
			current_piece.queue_free()
			spawn_piece(temp_piece)
		else:
			held_piece = current_piece.tetrominoe_data
			current_piece.queue_free()
			spawn_piece()
		hold_cd = true
		piece_held.emit(held_piece)

func try_to_rotate(direction: int) -> void:
	var new_coords: Array[Vector2i] = current_piece.get_rotation_coords(direction)
	if check_valid_cooords(new_coords):
		current_piece.rotate_tetrominoe(new_coords, direction)

func spawn_piece(piece_type: ShapeGeneric = null) -> void:
	if not piece_type:
		piece_type = next_pieces.pop_front()
		next_pieces.append(await piece_types.pick_random().new())
	current_piece = preload("res://source/tetrominoes/tetrominoe.tscn").instantiate()
	current_piece.initialize(piece_type, tile_size, Vector2i(piece_type.x_offset,TILE_Y_OFFSET))
	current_piece.piece_moved.connect(update_ghost_squares)
	piece_spawned.emit(next_pieces[0])
	add_child(current_piece)
	
func try_to_move(direction: Vector2i) -> void:
	var new_coords: Array[Vector2i] = current_piece.get_move_coords(direction)
	if check_valid_cooords(new_coords):
		current_piece.move_tetrominoe(new_coords, direction)

func find_bottom():
	var tiles_down: int = 1
	while true:
		var new_coords: Array[Vector2i] = current_piece.get_move_coords(Vector2i(0, tiles_down))
		if check_valid_cooords(new_coords):
			tiles_down += 1
		else:
			return current_piece.get_move_coords(Vector2i(0, tiles_down - 1))

func hard_drop() -> void:
	var target_coords = find_bottom()
	var tiles_down: int = int(current_piece.squares[0].position.y / tile_size)
	current_piece.move_tetrominoe(target_coords, Vector2i(0, tiles_down))
	bottom_reached()

func check_valid_cooords(coords: Array[Vector2i]) -> bool:
	var taken_tiles: Array[Vector2i]
	for tile: Vector2i in board_state:
		if board_state[tile] is Sprite2D:
			taken_tiles.append(tile)
	for coord in coords:
		if coord.x < 0 or coord.x > board_size.x -1:
			return false
		if coord.y > board_size.y -1:
			return false
		if coord in taken_tiles:
			return false
	return true

func bottom_reached() -> void:
	for square: Sprite2D in current_piece.squares:
		board_state[Vector2i(square.position / tile_size)] = square
		square.reparent(self)
	var completed_lines = find_lines()
	if completed_lines.size() > 0:
		clear_lines(completed_lines)
	if check_game_over():
		game_over.emit()
	else:
		hold_cd = false
		spawn_piece()

func check_game_over() -> bool:
	for tile: Vector2i in board_state.keys():
		if tile.y < 0 and board_state[tile] is Sprite2D:
			return true
	return false

func find_lines() -> Array[int]:
	var lines: Array[int] = []
	for y in range(board_size.y):
		var line_complete: bool = true
		for x in range(board_size.x):
			if not board_state[Vector2i(x,y)]:
				line_complete = false
				break
		if line_complete:
			lines.append(y)
	return lines

func clear_lines(lines: Array[int]) -> void:
	lines.sort()
	
	# First, remove the blocks in the lines to be cleared
	for line in lines:
		for x in range(board_size.x):
			var pos = Vector2i(x, line)
			if board_state[pos] is Sprite2D:
				board_state[pos].queue_free()
				board_state[pos] = null
	
	# Create a new board state that will hold the updated positions
	var new_board_state = {}
	for x in range(board_size.x):
		for y in range(board_size.y):
			new_board_state[Vector2i(x, y)] = null
	
	# For each position in the original board (from bottom to top)
	for y in range(board_size.y - 1, -1, -1):
		# Skip this row if it was a cleared line
		if y in lines:
			continue
			
		# Calculate how many cleared lines are below this row
		var shift_amount = 0
		for line in lines:
			if line > y:
				shift_amount += 1
		
		# The new position will be shifted down by the number of cleared lines below
		var new_y = y + shift_amount
		
		# Move all blocks in this row to their new positions
		for x in range(board_size.x):
			var current_pos = Vector2i(x, y)
			if board_state[current_pos] is Sprite2D:
				var sprite = board_state[current_pos]
				var new_pos = Vector2i(x, new_y)
				
				# Update the sprite's visual position
				sprite.position = Vector2(new_pos.x, new_pos.y) * tile_size
				
				# Store the sprite in the new board state
				new_board_state[new_pos] = sprite
	
	# Replace the old board state with the new one
	board_state = new_board_state
	
	# Let the parent node know how many lines have been cleared
	lines_cleared.emit(len(lines))

extends Node

enum game_states{RUNNING, STOPPED, PAUSED}

const TILE_SIZE: int = 32
const BOARD_X_OFFSET: int = 7
const BOARD_SIZE: Vector2i = Vector2i(10,20)
const LINES_PER_LEVEL: int = 10
const EXPECTED_FRAME_DURATION: float = 0.0167
const SCORE_MULTIPLIER: Dictionary = {
	1: 100
	, 2: 300
	, 3: 500
	, 4 :800
}
const LEVEL_SPEED: Dictionary = {
	0 : 53
	, 1 : 49
	, 2 : 45
	, 3 : 41
	, 4 : 37
	, 5 : 33
	, 6 : 28
	, 7 : 22
	, 8 : 17
	, 9 : 11
	, 10 : 10
	, 11 : 9
	, 12 : 8
	, 13 : 7
	, 14 : 6
	, 15 : 6
	, 16 : 5
	, 17 : 5
	, 18 : 4
	, 19 : 4
	, 20 : 3
}

var board: Board
var level: int
var total_lines: int
var score: int
var game_state: int

@onready var gui: Gui = $GUI

func _enter_tree() -> void:
	get_tree().paused = true
	game_state = game_states.STOPPED
	LoadSaveSettings.load_inputmap_from_file()

func _ready() -> void:
	$Settings.ready_to_close.connect(close_settings)
	gui.settings_clicked.settings_clicked.connect(on_settings_clicked)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		if game_state == game_states.STOPPED and not $Settings.visible:
			start()
		else:
			pause_game()

func start() -> void:
	# reset game state
	level = 0
	total_lines = 0
	score = 0
	
	# clean up GUI
	gui.level_number.text = str(0)
	gui.lines_number.text = str(0)
	gui.score_number.text = str(0)
	gui.next_piece_thumbnail.texture = null
	gui.held_piece_thumbnail.texture = null
	gui.info_screen.visible = false
	gui.info_screen.label.text = ''
	
	# start game
	game_state = game_states.RUNNING
	initialize_board()
	await board.spawn_piece()
	get_tree().paused = false

func pause_game() -> void:
	if game_state == game_states.PAUSED:
		game_state = game_states.RUNNING
		get_tree().paused = false
		gui.info_screen.visible = false
		return
	elif game_state == game_states.STOPPED:
		return
	game_state = game_states.PAUSED
	get_tree().paused = true
	gui.info_screen.label.text = "GAME PAUSED"
	gui.info_screen.visible = true

func initialize_board() -> void:
	if board:
		board.queue_free()
	board = preload("res://source/board/board.gd").new()
	board.process_mode = Node.PROCESS_MODE_PAUSABLE
	board.position.x = TILE_SIZE * BOARD_X_OFFSET
	board.initialize_board(BOARD_SIZE, TILE_SIZE, LEVEL_SPEED[level] * EXPECTED_FRAME_DURATION)
	board.lines_cleared.connect(on_lines_cleared)
	board.game_over.connect(on_game_over)
	board.piece_held.connect(on_piece_held)
	board.piece_spawned.connect(on_piece_spawned)
	$BoardElements.add_child(board)

func on_lines_cleared(lines_cleared: int) -> void:
	total_lines += lines_cleared
	gui.lines_number.text = str(total_lines)
	# we need to add 1 to level or else level 0 would award no points
	score += SCORE_MULTIPLIER[lines_cleared] * (level+1)
	gui.score_number.text = score_string(score)
	# integer divisions always return the floor as an int
	@warning_ignore("integer_division")
	if total_lines / LINES_PER_LEVEL > level:
		level_up()

func on_game_over() -> void:
	get_tree().paused = true
	gui.info_screen.visible = true
	gui.info_screen.label.text = '
		GAME OVER
		
		Your score: %s
		
		Press %s to play again
	' % [str(score),Utils.get_start_key_name()]
	game_state = game_states.STOPPED

func on_piece_held(piece_held: ShapeGeneric) -> void:
	gui.held_piece_thumbnail.texture = piece_held.thumbnail

func on_piece_spawned(piece_type: ShapeGeneric) -> void:
	gui.next_piece_thumbnail.texture = piece_type.thumbnail

func level_up() -> void:
	level += 1
	gui.level_number.text = str(level)
	board.gravity_cd = LEVEL_SPEED[level] * EXPECTED_FRAME_DURATION

func score_string(int_score: int) -> String:
	var digits: int = len(str(int_score))
	var str_score: String
	if digits in [1,2,3]:
		str_score = str(int_score)
	elif digits in [4,5,6]:
		@warning_ignore("integer_division")
		str_score = str(int_score/1000)+"K"
	elif digits in [7,8,9]:
		@warning_ignore("integer_division")
		str_score = str(int_score/1000000)+"M"
	elif digits in [10,11]:
		@warning_ignore("integer_division")
		str_score = str(int_score/1000000000)+"MM"
	else:
		str_score = "WTF"
	return str_score

func close_settings() -> void:
	pause_game()
	$Settings.visible = false

func on_settings_clicked() -> void:
	print("signal received")
	pause_game()
	$Settings.visible = true

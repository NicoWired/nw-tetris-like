class_name Gui
extends Control

@onready var level_number: Label = %LevelNumber
@onready var lines_number: Label = %LinesNumber
@onready var score_number: Label = %ScoreNumber
@onready var next_piece_thumbnail: TextureRect = $NextPiece/NextPieceThumbnail
@onready var held_piece_thumbnail: TextureRect = $HeldPiece/HeldPieceThumbnail
@onready var settings_clicked: TextureRect = $SettingsButton
@onready var info_screen: InfoScreen = $InfoScreen

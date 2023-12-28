extends "res://Code/character.gd"

@onready var whisperArea: Marker2D = $MeleeArea

func _ready():
	moreReady()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	processor()

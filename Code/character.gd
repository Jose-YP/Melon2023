extends StaticBody2D

@onready var sprite: Sprite2D = $Icon

func _ready():
	moreReady()

func moreReady(): #Lover will inherit from Character so moreReady can be called on both scripts to keep them same
	pass

func _process(_delta):
	processor()

func processor(): #The same applies to processor and process
	pass

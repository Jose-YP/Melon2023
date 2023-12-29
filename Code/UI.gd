extends CanvasLayer

@onready var time: Timer = $Timer
@onready var timerText: RichTextLabel = $TimerText
@onready var scoreText: RichTextLabel = $ScoreText
@onready var suspectBar: TextureProgressBar = $SuspicionBar

var totalTime: int = 0
var totalScore: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	time.set_paused(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func tweenSuspectBar():
	pass

func riseScore():
	totalScore += 1
	scoreText.clear()
	scoreText.append_text(str("Score: ", totalScore))

func _on_timer_timeout():
	totalTime += 1
	var timeText = str("[color=green]",totalTime,"[/color]")
	timerText.clear()
	
	if totalTime > 5:
		timeText = str("[color=red]",totalTime,"[/color]")
	
	timerText.append_text(str("Time: ", timeText))

func _on_main_game_rise_score():
	riseScore()

func _on_main_game_change_suspect(ammount):
	suspectBar.value += ammount
	tweenSuspectBar()

extends CanvasLayer

@onready var time: Timer = $Timer
@onready var timerText: RichTextLabel = $TimerText
@onready var scoreText: RichTextLabel = $ScoreText
@onready var suspectBar: TextureProgressBar = $SuspicionBar

signal startSpawning

var totalTime: int = 0
var totalScore: int = 0

#----------------------------------------------
#INITALIZATION
#----------------------------------------------
func _ready():
	time.set_paused(false)

func _process(_delta):
	pass

#----------------------------------------------
#UPDATE FUNCTIONS
#----------------------------------------------
func tweenSuspectBar():
	pass

func riseScore():
	totalScore += 1
	scoreText.clear()
	scoreText.append_text(str("Score: ", totalScore))

#----------------------------------------------
#SIGNALS
#----------------------------------------------
func _on_timer_timeout():
	totalTime += 1
	var timeText = str("[color=green]",totalTime,"[/color]")
	timerText.clear()
	
	if totalTime == 30:
		startSpawning.emit()
	
	if totalTime > 30:
		timeText = str("[color=red]",totalTime,"[/color]")
	elif totalTime > 10:
		timeText = str("[color=yellow]",totalTime,"[/color]")
	
	timerText.append_text(str("Time: ", timeText))

func _on_main_game_rise_score():
	riseScore()

func _on_main_game_change_suspect(ammount):
	suspectBar.value += ammount
	tweenSuspectBar()

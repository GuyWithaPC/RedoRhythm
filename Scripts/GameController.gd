extends Node2D

enum ARROW {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

const arrowNames: Dictionary = {
	ARROW.UP: "Up",
	ARROW.RIGHT: "Right",
	ARROW.DOWN: "Down",
	ARROW.LEFT: "Left"
}

var arrowQueues: Array[Array] = [
	[],
	[],
	[],
	[]
]

var messageQueue: Dictionary = {}

var chart: Dictionary

var time: float = 0.0
var reversing: bool = false
var reverse_speed: float = 3.0

const arrowScene = preload("res://Objects/arrow.tscn")

@export var bpm: int = 120 ## the BPM of the current song
@export var fudgeThreshold: float = 0.0 ## the "fudge factor" (how much leeway to give note generation)
@export var distance: int = 256 ## the distance from note spawners to notes
@export var bpmSpeedFactor: float = 1.5 ## the multiple of bpm that the pixel per second speed is
@export var chartName: String = "zazie"

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_chart()
#	var parser = ChartParser.new()
#	chart = parser.loadChart(chartName)
#	$Song.stream = load(chart.song)
#	bpm = chart.bpm
#	messageQueue = chart.messages
#	for time in chart.left:
#		schedule(ARROW.LEFT,time)
#	for time in chart.right:
#		schedule(ARROW.RIGHT,time)
#	for time in chart.up:
#		schedule(ARROW.UP,time)
#	for time in chart.down:
#		schedule(ARROW.DOWN,time)
#	$Song.play()

func reset_chart():
	var parser = ChartParser.new()
	chart = parser.loadChart(chartName)
	arrowQueues = [[],[],[],[]]
	$Song.stream = load(chart.song)
	bpm = chart.bpm
	messageQueue = chart.messages
	for time in chart.left:
		schedule(ARROW.LEFT,time)
	for time in chart.right:
		schedule(ARROW.RIGHT,time)
	for time in chart.up:
		schedule(ARROW.UP,time)
	for time in chart.down:
		schedule(ARROW.DOWN,time)
	$Song.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if reversing:
		time -= delta*reverse_speed
		reverse_speed *= pow(2.0,delta)
		if time <= 0:
			time = 0
			reversing = false
			reset_chart()
	else:
		reverse_speed = 5
	# do arrow spawning stuff
	time += delta
	checkMessages(time)
	for arrow in range(4):
		if hasSchedule(arrow,time):
			# make a new moving arrow at the corresponding spawner
			var newArrow = arrowScene.instantiate()
			newArrow.speed = bpm / bpmSpeedFactor
			add_child(newArrow)
			newArrow.position = $ArrowSpawners.get_node(arrowNames[arrow]).position
			newArrow.direction = arrow
	# do arrow removing stuff
	if Input.is_action_just_pressed("up"):
		if $ArrowAreas/Up.get_overlapping_areas().is_empty():
			reset()
		else:
			$ArrowAreas/Up.get_overlapping_areas()[0].get_parent().kill()
	if Input.is_action_just_pressed("right"):
		if $ArrowAreas/Right.get_overlapping_areas().is_empty():
			reset()
		else:
			$ArrowAreas/Right.get_overlapping_areas()[0].get_parent().kill()
	if Input.is_action_just_pressed("down"):
		if $ArrowAreas/Down.get_overlapping_areas().is_empty():
			reset()
		else:
			$ArrowAreas/Down.get_overlapping_areas()[0].get_parent().kill()
	if Input.is_action_just_pressed("left"):
		if $ArrowAreas/Left.get_overlapping_areas().is_empty():
			reset()
		else:
			$ArrowAreas/Left.get_overlapping_areas()[0].get_parent().kill()

func reset():
	for arrow in get_tree().get_nodes_in_group("arrows"):
		arrow.reverse()
	$Song.stop()
	reversing = true
	

func schedule(arrow: ARROW, timing: float):
	var speed = bpm / bpmSpeedFactor
	var correctedTiming = timing - (distance / speed)
	arrowQueues[arrow].append(correctedTiming)

func hasSchedule(arrow: ARROW, currentTime: float) -> bool:
	if arrowQueues[arrow].is_empty():
		return false
	if arrowQueues[arrow][0] <= (currentTime + fudgeThreshold):
		arrowQueues[arrow].pop_front()
		return true
	return false

func checkMessages(currentTime: float):
	for key in messageQueue.keys():
		if key <= (currentTime + fudgeThreshold):
			$MessageText.text = messageQueue[key]
			messageQueue.erase(key)
			print(messageQueue)


func _on_fail_zone_area_entered(area):
	if !reversing:
		reset()

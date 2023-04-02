extends Node2D

var selected_item: int
@onready var arrows = $UI/Menu/Arrows
@onready var list = $UI/Menu/LevelList
var currentLevel: Node2D
const levelScene = preload("res://Scenes/main.tscn")
var playing = false

var levelCharts = {
	0: "tutorial",
	1: "song1",
	2: "test"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/Menu/LevelList.grab_focus()

func startLevel(chartName: String):
	playing = true
	$UI.hide()
	currentLevel = levelScene.instantiate()
	currentLevel.chartName = chartName
	self.add_child(currentLevel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected_item != null:
		arrows.show()
		arrows.position.y = lerp(arrows.position.y,selected_item*18.0+8.0,delta*5.0)
	else:
		arrows.hide()
	
	if playing:
		if currentLevel.won and $WinTimer.is_stopped():
			$WinTimer.start()


func _on_level_list_item_selected(index):
	selected_item = index

func _on_level_list_item_activated(index):
	startLevel(levelCharts[index])


func _on_win_timer_timeout():
	playing = false
	currentLevel.queue_free()
	$UI.show()
	$UI/Menu/LevelList.grab_focus()

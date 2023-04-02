extends Node2D

@export var speed: float = 0 ## arrow speed upwards, in pixels per second
@export var direction: int = 0: ## arrow direction, meant to coincide with GameController.ARROW directions
	set(value):
		direction = value
		$Sprite.frame = direction
	get:
		return direction

const particleColor: Array = [
	Color("d95763"),
	Color("fbf236"),
	Color("5fcde4"),
	Color("99e550")
]

var reversing = false
var reverse_speed = 3.0
var speed_before: float

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.frame = direction

func kill():
	$Collider.monitorable = false
	$Particles.modulate = particleColor[direction]
	$Particles.emitting = true
	$Sprite.hide()

func reverse():
	if !reversing:
		speed_before = speed
		$Sprite.show()
		speed = -reverse_speed*speed_before
		reversing = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y -= speed*delta
	if reversing and position.y >= 256:
		self.queue_free()
	if reversing:
		speed = -reverse_speed*speed_before
		reverse_speed *= pow(2.0,delta)
	var clickable = false
	for area in $Collider.get_overlapping_areas():
		if "ArrowAreas" in area.get_parent().name:
			clickable = true
	if clickable:
		$Sprite.modulate = lerp($Sprite.modulate,Color(1.0,1.0,1.0,1.0),delta*abs(speed/5))
	else:
		$Sprite.modulate = lerp($Sprite.modulate,Color(1.0,1.0,1.0,0.5),delta*abs(speed/5))

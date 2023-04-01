extends AnimatedSprite2D

@export var speed: float = 0 ## arrow speed upwards, in pixels per second
@export var direction: int = 0: ## arrow direction, meant to coincide with GameController.ARROW directions
	set(value):
		direction = value
		frame = direction
	get:
		return direction

# Called when the node enters the scene tree for the first time.
func _ready():
	frame = direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y -= speed*delta

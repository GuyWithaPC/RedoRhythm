extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.scale = lerp(self.scale,Vector2(1.0,1.0),delta*25)

func setText(newText: String):
	self.text = newText
	self.scale = Vector2(1.25,1.25)

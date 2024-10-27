extends Sprite2D
@export var range : float
@export var speed : float 

var startY : float
var timer : float

# Called when the node enters the scene tree for the first time.
func _ready():
	startY = position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	position.y = position.y + sin(timer + 0.5) * range

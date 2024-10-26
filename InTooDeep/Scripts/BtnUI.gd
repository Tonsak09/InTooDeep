extends Button

@export var maxScaleHover : float
@export var hoverScaleSpeed : float  
@export var hoverCurve : Curve 
@export var targetScaleModClick : float 

@export var scaleMult : float

var isHover : bool
var isClicked : bool

var hoverL : float

var startY; 

func _ready():
	isHover = false 
	startY = global_position.y

func _process(delta):
	if isHover:
		hoverL =  clamp(hoverL + (hoverScaleSpeed * delta), 0, 1)
	else:
		hoverL =  clamp(hoverL - (hoverScaleSpeed * delta), 0, 1)
	
	var s = lerp(1.0, maxScaleHover, hoverCurve.sample(hoverL))
	scale = Vector2(scaleMult * s, s)

func OnHover():
	isHover = true 

func OnLeave():
	isHover = false 

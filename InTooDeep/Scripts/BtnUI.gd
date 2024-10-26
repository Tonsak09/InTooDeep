extends Button

@export var maxScaleHover : float
@export var hoverScaleSpeed : float  
@export var hoverCurve : Curve 
@export var targetScaleModClick : float 

@export var scaleMult : float

@export var clickTimer : Timer 
@export var clickCurve : Curve

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
	
	if isClicked:
		var l = 1.0 - (clickTimer.time_left / clickTimer.wait_time)
		
		if l >= 1.0:
			isClicked = false 
		else:
			l = clickCurve.sample(l)
			s -= l * targetScaleModClick
	
	scale = Vector2(scaleMult * s, s)

func OnHover():
	isHover = true 

func OnLeave():
	isHover = false 

func OnClick():
	clickTimer.start()
	isClicked = true 

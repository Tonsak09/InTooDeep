extends Sprite2D

@export var textLabel : Label

var text : String
var displayed : String
var curr : int

func  _ready():
	SetDialogue("This is just a big test")

func SetDialogue(t : String):
	text = t;
	textLabel.text = ""
	curr = 0

func AddChar():
	if textLabel.text.length() >= text.length():
		return
	
	textLabel.text += text[curr]
	curr += 1


extends Control

@export var childA : Control
@export var childB : Control

func _ready():
	pass # Replace with function body.

func _process(delta):
	if abs(childA.scale.x) > abs(childB.scale.x):
		childA.z_index = 1
		childB.z_index = 0
	else:
		childA.z_index = 0
		childB.z_index = 1

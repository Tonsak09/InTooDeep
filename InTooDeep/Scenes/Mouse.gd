extends Node2D

@export var sprite : Sprite2D
@export var holdTexture : Texture
@export var clickTexture : Texture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	global_position = get_viewport().get_mouse_position() - get_viewport_rect().size / 2.0
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		sprite.texture = clickTexture
	else:
		sprite.texture = holdTexture

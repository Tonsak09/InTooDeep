extends Sprite2D
@export var mat : ShaderMaterial


var timer : float 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta;
	mat.set_shader_parameter("Dither", remap(sin(timer), -1, 1, 0, 2) );

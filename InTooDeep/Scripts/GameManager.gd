extends Node2D

# - Player choices
# - States { StartScreen, Knock, FadingToOut, OutlineCharacter, ResultCharacter, FadingToIn, GameOver}




@export var gameState : GameStates;
enum GameStates
{
	START_SCREEN,
	KNOCK,
	FADING_TO_OUT,
	OUTLINE_CHARACTER,
	RESULT_CHARACTER,
	FADING_TO_IN,
	GAME_OVER
}

@export_category("Characters")
@export var clientTextures : Array[Texture2D]
@export var clientText : Array[String]
@export var copTextures : Array[Texture2D]
@export var copText : Array[String]
@export var childTextures : Array[Texture2D]
@export var childText : Array[String]

@export_category("Scene Folders")
@export var startScreen : Node2D
@export var hallway : Node2D
@export var inside : Node2D
@export var gameOver : Node2D

@export_category("Audio")
@export var knockAudio : AudioStreamPlayer2D

@export_category("Timers")
@export var ditherTimer : Timer

@export_category("Curves")
@export var ditherCurve : Curve

var currChar : CharacterType;
enum CharacterType 
{
	CHILD = 0,
	CLIENT = 1,
	COP = 2
}

var isCorrect : bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match gameState:
		GameStates.START_SCREEN:
			StartScreen_State()
		GameStates.KNOCK:
			Knock_State()
		GameStates.FADING_TO_OUT:
			FadingToOut_State()
		GameStates.OUTLINE_CHARACTER:
			OutlineCharacter_State()
		GameStates.RESULT_CHARACTER:
			ResultCharacter_State()
		GameStates.FADING_TO_IN:
			FadingToIn_State()
		GameStates.GAME_OVER:
			GameOver_State()

# Title screen that gives some credits and
# allows the player to start the game when
# they left-click 
func StartScreen_State():
	startScreen.visible = true 
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		startScreen.visible = false
		
		ResetGame()
		gameState = GameStates.KNOCK

# Simply is used to play the audio and set
# up the next state 
func Knock_State():
	
	# Display base text "Left click to get door..." 
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		ditherTimer.start(); # Begin timer 
		gameState = GameStates.FADING_TO_OUT;

# Animates the door ditherring out and the 
# hallway animating in. On summoning the
# characters activates their dialogue 
func FadingToOut_State():
	var l = 1.0 - (ditherTimer.time_left / ditherTimer.wait_time)
	
	if(l >= 1.0):
		# Play audio 
		# Activate character text 
		gameState = GameStates.OUTLINE_CHARACTER

# Player can decide which button to press. 
func OutlineCharacter_State():
	hallway.visible = true; 

# Reveals what the player's choice resulted
# in 
func ResultCharacter_State():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Check bool if correct or incorrect 
		
		if isCorrect:
			ditherTimer.start(); # Begin timer 
			gameState = GameStates.FADING_TO_IN
		else:
			gameState = GameStates.GAME_OVER

# Character fades away along with key hole.
# Then door fades back in 
func FadingToIn_State():
	var l = 1.0 - (ditherTimer.time_left / ditherTimer.wait_time)
	
	if(l >= 1.0):
		# Play audio 
		# Activate character text 
		gameState = GameStates.KNOCK

# Game over stats fade in over screen 
func GameOver_State():
	pass



func ResetGame():
	knockAudio.play();
	
	var character = randi_range(0, 2) 
	currChar = character







func OnCandyBtn():
	if gameState != GameStates.OUTLINE_CHARACTER:
		return
	
	# Is correct choice? 
	
	gameState = GameStates.RESULT_CHARACTER

func OnContrabandBtn():
	if gameState != GameStates.OUTLINE_CHARACTER:
		return
	
	# Is correct choice? 
	
	gameState = GameStates.RESULT_CHARACTER

func OnPassBtn():
	if gameState != GameStates.OUTLINE_CHARACTER:
		return
	
	# Is correct choice? 
	
	gameState = GameStates.RESULT_CHARACTER

extends Node2D



@export var gameState : GameStates;
enum GameStates
{
	START_SCREEN,		# Simply introduces the game 
	KNOCK,				# Plays 
	FADING_TO_OUT,		# Fades character in
	OUTLINE_CHARACTER,	# Waits for user input 
	RESULT_CHARACTER,	# Shows result of choice 
	FADING_TO_IN,		# Fades character out 
	GAME_OVER			# Overlays 
}

@export_category("Money")
@export var moneyGain : float
@export var moneyLoss : float 


@export_category("Characters")
@export var clientTextures : Array[Texture2D]
@export var clientText : Array[String]
@export var copTextures : Array[Texture2D]
@export var copText : Array[String]
@export var childTextures : Array[Texture2D]
@export var childText : Array[String]

@export_category("Scene Folders")
@export var startScreen : Node2D
@export var btns : Control
@export var contAdvice : Control
@export var inside : Node2D
@export var gameOver : Node2D

@export_category("Audio")
@export var knockAudio : AudioStreamPlayer2D

@export_category("Timers")
@export var ditherTimer : Timer

@export_category("Curves")
@export var ditherCurve : Curve

@export_category("Sprites")
@export var characterSprite : Sprite2D

@export_category("Dialogue")
@export var childIntro : Array[String]
@export var clientIntro : Array[String]
@export var copIntro : Array[String] # Will also use intros of other characters 


@export_category("Debug")
@export var stateLabel : Label
@export var charLabel : Label
@export var moneyLabel : Label


var currChar : CharacterType;
enum CharacterType 
{
	CHILD = 0,
	CLIENT = 1,
	COP = 2
}

var isCorrect : bool
var money : float 

func _ready():
	isCorrect = true 
	money = 50.0;

func _process(delta):
	StateMachine()
	DebugHelper()

func DebugHelper():
	stateLabel.text = str(gameState)
	match gameState:
		GameStates.START_SCREEN:
			stateLabel.text = "START_SCREEN"
		GameStates.KNOCK:
			stateLabel.text = "KNOCK"
		GameStates.FADING_TO_OUT:
			stateLabel.text = "FADING_TO_OUT"
		GameStates.OUTLINE_CHARACTER:
			stateLabel.text = "OUTLINE_CHARACTER"
		GameStates.RESULT_CHARACTER:
			stateLabel.text = "RESULT_CHARACTER"
		GameStates.FADING_TO_IN:
			stateLabel.text = "FADING_TO_IN"
		GameStates.GAME_OVER:
			stateLabel.text = "GAME_OVER"
	
	
	match currChar:
		CharacterType.CHILD:
			charLabel.text = "CHILD";
		CharacterType.CLIENT:
			charLabel.text = "CLIENT";
		CharacterType.COP:
			charLabel.text = "COP";
	
	moneyLabel.text = str(money)

func StateMachine():
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
	ditherTimer.start(); # Begin timer 
	knockAudio.play(); # Play audio 
	
	ResetGame()
	
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
	btns.visible = true; 

# Reveals what the player's choice resulted
# in 
func ResultCharacter_State():
	
	btns.visible = false; 
	contAdvice.visible = true 
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Check bool if correct or incorrect 
		contAdvice.visible = false 
		
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
	var character = randi_range(0, 2) 
	currChar = character
	# Set charactter texture 







func OnCandyBtn():
	if gameState != GameStates.OUTLINE_CHARACTER:
		return
	
	# Is correct choice? 
	match currChar:
		CharacterType.CHILD:
			gameState = GameStates.RESULT_CHARACTER
		CharacterType.CLIENT:
			money -= moneyLoss
			gameState = GameStates.RESULT_CHARACTER 
		CharacterType.COP:
			gameState = GameStates.RESULT_CHARACTER 
	

func OnContrabandBtn():
	if gameState != GameStates.OUTLINE_CHARACTER:
		return
	
	# Is correct choice? 
	match currChar:
		CharacterType.CHILD:
			gameState = GameStates.GAME_OVER
		CharacterType.CLIENT:
			money += moneyGain
			gameState = GameStates.RESULT_CHARACTER
		CharacterType.COP:
			gameState = GameStates.GAME_OVER 


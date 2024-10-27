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
@export var moneyDis : Label


@export_category("Clients")
@export var clientOutlineTextures : Array[Texture2D]
@export var clientDisplayTextures : Array[Texture2D]
@export var clientCandyTextures : Array[Texture2D]
@export var clientDrugsTextures : Array[Texture2D]
@export_category("Detective")
@export var detectiveOutlineTextures : Array[Texture2D]
@export var detectiveDisplayTextures : Array[Texture2D]
@export var detectiveCandyTextures : Array[Texture2D]
@export var detectiveDrugsTextures : Array[Texture2D]
@export_category("Children")
@export var childOutlineTextures : Array[Texture2D]
@export var childDisplayTextures : Array[Texture2D]
@export var childCandyTextures : Array[Texture2D]
@export var childDrugsTextures : Array[Texture2D]

@export_category("Scene Folders")
@export var startScreen : Node2D
@export var btns : Control
@export var contAdvice : Control
@export var inside : Node2D
@export var gameOver : Node2D

@export_category("Audio")
@export var knockAudio : AudioStreamPlayer2D
@export var goodAudio : AudioStreamPlayer2D
@export var badAudio : AudioStreamPlayer2D

@export_category("Timers")
@export var ditherTimer : Timer
@export var pauseTimer : Timer 
@export var countdownTimer : Timer 
@export var countTimerBar : ProgressBar

@export_category("Curves")
@export var ditherInCurve : Curve
@export var ditherOutCurve : Curve

@export_category("Character Rendering")
@export var characterSprite : Sprite2D
@export var characterShaderMaterial : ShaderMaterial

@export_category("Dialogue")
@export var dialogueManager : Node2D
@export var typeSpeed : float 
@export var childIntro : Array[String]
@export var clientIntro : Array[String]
@export var copIntro : Array[String] # Will also use intros of other characters 

@export_category("Enddetails")
@export var finalScore : Label
@export var finalTime : Label

@export_category("Debug")
@export var stateLabel : Label
@export var charLabel : Label
@export var moneyLabel : Label


var charVarient : int 
var currChar : CharacterType;
enum CharacterType 
{
	CHILD = 0,
	CLIENT = 1,
	COP = 2
}

var isCorrect : bool
var isCandy : bool 
var money : float 
var time : float 

var roundCount : int

func _ready():
	isCorrect = true 
	isCandy = true 
	money = 50.0;

func _process(delta):
	StateMachine(delta)
	#DebugHelper()

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

func StateMachine(delta):
	
	if gameState != GameStates.START_SCREEN && gameState != GameStates.GAME_OVER:
		time += delta 
		
		moneyDis.text = str(money)
		
		var interp = countdownTimer.time_left / countdownTimer.wait_time
		countTimerBar.value = interp
		if interp <= 0.0:
			gameState = GameStates.GAME_OVER
	
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
	dialogueManager.visible = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		startScreen.visible = false
		btns.visible = true
		characterSprite.visible = true
		ResetGame()
		gameState = GameStates.KNOCK

# Simply is used to play the audio and set
# up the next state 
func Knock_State():
	ditherTimer.start(); # Begin timer 
	knockAudio.play(); # Play audio 
	dialogueManager.visible = true 
	
	knockAudio.play()
	
	ResetGame()
	gameState = GameStates.FADING_TO_OUT;

# Animates the door ditherring out and the 
# hallway animating in. On summoning the
# characters activates their dialogue 
func FadingToOut_State():
	var l = 1.0 - (ditherTimer.time_left / ditherTimer.wait_time)
	SetCharacterDither(ditherOutCurve.sample(l) * 2.0);
	
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
	countdownTimer.paused = true
	if pauseTimer.is_stopped():
		contAdvice.visible = true 
		
		# Set to holding item 
		match currChar:
			CharacterType.CHILD: 
				if isCandy:
					SetCharacterTexture(childCandyTextures[charVarient])
				else:
					SetCharacterTexture(childDrugsTextures[charVarient])
			CharacterType.CLIENT:
				if isCandy:
					SetCharacterTexture(clientCandyTextures[charVarient])
				else:
					SetCharacterTexture(clientDrugsTextures[charVarient])
			CharacterType.COP:
				if isCandy:
					SetCharacterTexture(detectiveCandyTextures[charVarient])
				else:
					SetCharacterTexture(detectiveDrugsTextures[charVarient])
		
		# Check bool if correct or incorrect 
		contAdvice.visible = false 
		
		if isCorrect:
			ditherTimer.start(); # Begin timer 
			gameState = GameStates.FADING_TO_IN
			goodAudio.play()
		else:
			gameState = GameStates.GAME_OVER
			
	else:
		match currChar:
			CharacterType.CHILD:
				SetCharacterTexture(childDisplayTextures[charVarient])
			CharacterType.CLIENT:
				SetCharacterTexture(clientDisplayTextures[charVarient])
			CharacterType.COP:
				SetCharacterTexture(detectiveDisplayTextures[charVarient])

# Character fades away along with key hole.
# Then door fades back in 
func FadingToIn_State():
	var l = (ditherTimer.time_left / ditherTimer.wait_time)
	SetCharacterDither(ditherInCurve.sample(l) * 2.0);
	if(1.0 - l >= 1.0):
		# Play audio 
		# Activate character text 
		gameState = GameStates.KNOCK

# Game over stats fade in over screen 
func GameOver_State():
	gameOver.visible = true 
	finalScore.text = "Final Score: " + str(money)
	finalTime.text = "Time in Business: " + str(int(time)) + "s"
	
	match currChar:
			CharacterType.CHILD: 
				if isCandy:
					SetCharacterTexture(childCandyTextures[charVarient])
				else:
					SetCharacterTexture(childDrugsTextures[charVarient])
			CharacterType.CLIENT:
				if isCandy:
					SetCharacterTexture(clientCandyTextures[charVarient])
				else:
					SetCharacterTexture(clientDrugsTextures[charVarient])
			CharacterType.COP:
				if isCandy:
					SetCharacterTexture(detectiveCandyTextures[charVarient])
				else:
					SetCharacterTexture(detectiveDrugsTextures[charVarient])
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		gameOver.visible = false
		roundCount = 0
		
		ResetGame()
		gameState = GameStates.START_SCREEN


func ResetGame():
	var character = randi_range(0, 2) 
	currChar = character
	countdownTimer.paused = false
	roundCount += 1
	countdownTimer.wait_time = lerp(15.0, 5.0, clamp(float(roundCount) / 10.0, 0.0, 1.0))
	
	countdownTimer.start()
	 
	# Set charactter texture 
	match currChar:
		CharacterType.CHILD:
			charVarient = randi_range(0, childOutlineTextures.size() - 1) # Sets variant 
			#characterSprite.texture = childOutlineTextures[charVarient]
			SetCharacterTexture(childOutlineTextures[charVarient])
			
			dialogueManager.SetDialogue(childIntro[randi_range(0, childIntro.size() - 1)])
		CharacterType.CLIENT:
			charVarient = randi_range(0, clientOutlineTextures.size() - 1) # Sets variant 
			#characterSprite.texture = clientOutlineTextures[charVarient]
			SetCharacterTexture(clientOutlineTextures[charVarient])
			
			dialogueManager.SetDialogue(clientIntro[randi_range(0, clientIntro.size() - 1)])
		CharacterType.COP:
			charVarient = randi_range(0, detectiveOutlineTextures.size() - 1) # Sets variant 
			#characterSprite.texture = detectiveOutlineTextures[charVarient]
			SetCharacterTexture(detectiveOutlineTextures[charVarient])
			
			dialogueManager.SetDialogue(copIntro[randi_range(0, copIntro.size() - 1)])


func OnCandyBtn():
	if gameState != GameStates.OUTLINE_CHARACTER:
		return
	isCandy = true 
	# Is correct choice? 
	match currChar:
		CharacterType.CHILD:
			gameState = GameStates.RESULT_CHARACTER
			pauseTimer.start()
		CharacterType.CLIENT:
			money -= moneyLoss
			gameState = GameStates.RESULT_CHARACTER 
			pauseTimer.start()
		CharacterType.COP:
			gameState = GameStates.RESULT_CHARACTER 
			pauseTimer.start()
	

func OnContrabandBtn():
	if gameState != GameStates.OUTLINE_CHARACTER:
		return
	isCandy = false 
	# Is correct choice? 
	match currChar:
		CharacterType.CHILD:
			gameState = GameStates.GAME_OVER
			badAudio.play()
		CharacterType.CLIENT:
			money += moneyGain
			gameState = GameStates.RESULT_CHARACTER
			pauseTimer.start()
		CharacterType.COP:
			gameState = GameStates.GAME_OVER 
			badAudio.play()

func SetCharacterTexture(text : Texture):
	characterSprite.texture = text
	characterSprite.material.set_shader_parameter("MainTexture", text)

func SetCharacterDither(dither : float):
	characterSprite.material.set_shader_parameter("Dither", dither)

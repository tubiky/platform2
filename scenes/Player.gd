extends KinematicBody2D

var gravity = 1000
var velocity = Vector2.ZERO
var maxHorizontalSpeed = 140
var horizontalAcceleration = 1500
var jumpSpeed = 300
var jumpTerminationMultiplier = 3
var hasDoubleJump = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var moveVector = get_movement_vector()
	
	velocity.x += moveVector.x * horizontalAcceleration * delta
	
	if (moveVector.x == 0):
		# frame rate independent lerp
		velocity.x = lerp(0, velocity.x, pow(2, -40 * delta))
		
	velocity.x = clamp(velocity.x, -maxHorizontalSpeed, maxHorizontalSpeed)
	
	if (moveVector.y < 0 && (is_on_floor() || !$CoyoteTimer.is_stopped() || hasDoubleJump)):
		velocity.y = moveVector.y * jumpSpeed
		if (!is_on_floor() && $CoyoteTimer.is_stopped()):
			hasDoubleJump = false
		$CoyoteTimer.stop()
		
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jumpTerminationMultiplier * delta
	else:
		velocity.y += gravity * delta
		
	var wasOnFloor = is_on_floor()
	
	# move_and_slide updates the is_on_floor state internally
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if (wasOnFloor && !is_on_floor()):
		$CoyoteTimer.start()
		
	if (is_on_floor()):
		hasDoubleJump = true
	
	update_animation()

func get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0
	
	return moveVector

func update_animation():
	var moveVec = get_movement_vector()
	
	if (!is_on_floor()):
		$AnimatedSprite.play("jump")
	elif (moveVec.x != 0):
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")

	if (moveVec.x != 0):
		$AnimatedSprite.flip_h = true if moveVec.x > 0 else false

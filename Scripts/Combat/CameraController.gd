extends CharacterBody2D

const SPEED = 600.0

var zoomSpeed: float = 0.05
var zoomMin: float = 0.5
var zoomMax: float = 2.0
var dragSensitivity: float = 1.0

func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		position -= event.relative * dragSensitivity / %Camera2D.zoom
		
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			%Camera2D.zoom += Vector2(zoomSpeed, zoomSpeed)
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			%Camera2D.zoom -= Vector2(zoomSpeed, zoomSpeed)
			
		%Camera2D.zoom = clamp(%Camera2D.zoom, Vector2(zoomMin, zoomMin), Vector2(zoomMax, zoomMax))

func _physics_process(delta):
	var inputVector = Vector2.ZERO
	inputVector.x = Input.get_axis("left", "right")
	inputVector.y = Input.get_axis("up", "down")
	inputVector.normalized()

	if inputVector:
		velocity = inputVector * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

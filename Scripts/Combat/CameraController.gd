extends CharacterBody2D

var cameraLocked = false

const SPEED = 600.0

var zoomSpeed: float = 0.05
var zoomMin: float = 0.5
var zoomMax: float = 2.0
var dragSensitivity: float = 1.0

func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and !cameraLocked:
		position -= event.relative * dragSensitivity / %Camera2D.zoom
		
	if event is InputEventMouseButton and !cameraLocked:
		
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

	if !cameraLocked:
		if inputVector:
			velocity = inputVector * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)

		move_and_slide()

func moveTo(newPosition):
	position = newPosition

func tweenTo(newPosition):
	var tween = create_tween()
	tween.tween_property(self, "position", newPosition, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

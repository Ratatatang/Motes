extends Entity
class_name Player

@onready var line = $Line2D
@onready var arc = $Arc2D
@onready var arcLine = $Arc2D/Line2D

var linePath : Array[Vector2i]

func _init():
	deck = ["Ignite", "Ignite", "Ignite", "Ignite", "Ignite", "FireArrow", "FireArrow", "FireArrow", "FireArrow", "FireArrow"]
	curDeck = deck.duplicate()
	maxHandSize = 8
	hand = {}
	maxAP = 30
	curAP = 30
	maxHP = 20
	curHP = 20

func _physics_process(delta):
	super(delta)
	
	if(linePath != pathToMouse()):
		line.clear_points()
		linePath = pathToMouse()
		line.position =- (global_position-Vector2(32,32))
		for point in linePath:
			line.add_point(tilemap.map_to_local(point)-Vector2(32,32))
		
		drawCurve()


func drawCurve():
	var curve = arc.curve
		
	curve.set_point_position(1, tilemap.map_to_local(tilemap.local_to_map(get_global_mouse_position()))-Vector2(32, 32))
	
	setLinePointsToBezierCurve(arcLine, curve.get_point_position(0), curve.get_point_position(1),
								curve.get_point_out(0), curve.get_point_in(1))

func enableLine():
	if currentPath.is_empty():
		updateImpassable()
		line.visible = true
		$ColorRect.color = "26cd00"

func disableLine():
	line.visible = false
	$ColorRect.color = "1a9900"

func pathToMouse() -> Array[Vector2i]:
	var idPath = []
	
	if moving:
		pass
	else:
		idPath = astarGrid.get_id_path(
			tilemap.local_to_map(global_position), 
			tilemap.local_to_map(get_global_mouse_position()))
	
	return idPath

func setPath(path = get_global_mouse_position()):
	super(path)

func setLinePointsToBezierCurve(line: Line2D, a: Vector2, b: Vector2, outA: Vector2, inB: Vector2):
	var curve := Curve2D.new()
	curve.add_point(a, Vector2.ZERO, outA)
	curve.add_point(b, inB, Vector2.ZERO)
	line.points = curve.get_baked_points()

func incrementAP(num : int) -> void:
	curAP += num
	
func enoughAP(cost : int) -> bool:
	if(cost <= curAP):
		return true
	else:
		return false



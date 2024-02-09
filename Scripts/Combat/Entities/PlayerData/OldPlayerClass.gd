extends Entity

@onready var line = $Line2D
@onready var arc = $Arc2D
@onready var ray = $RayCast2D
@onready var arcLine = $Arc2D/Line2D

var linePath : Array[Vector2i]

var arcTargeting = []
var viableTarget = false
var currentArcTargets = {}

func _init():
	deck = ["Ignite", "Ignite", "Ignite", "Ignite", "Ignite", "FireArrow", "FireArrow", "FireArrow", "FireArrow", "FireArrow"]
	maxHandSize = 8
	maxAP = 30
	maxHP = 20

func _physics_process(delta):
	super(delta)
	
	if(linePath != pathToMouse() and line.visible):
		line.clear_points()
		linePath = pathToMouse()
		line.position =- (global_position-Vector2(32,32))
		for point in linePath:
			line.add_point(tilemap.map_to_local(point)-Vector2(32,32))
	
	if(arc.visible):
		arcLine.position =- (global_position-Vector2(32,32))
		viableTarget = false
		currentArcTargets = {}
		var currentMouseTarget = tilemap.local_to_map(get_global_mouse_position())
		
		if(checkLineOfSight(currentMouseTarget)):
			for target in arcTargeting:
			
				if(target == "Tiles"):
					var mouseData = tilemap.get_cell_tile_data(0, currentMouseTarget)
				
					if mouseData != null and !mouseData.get_custom_data("impassable"):
						viableTarget = true
						currentArcTargets.merge({target: currentMouseTarget})
					
				if(target == "Enemies" or target == "Self" or target == "Allies"):
					if(entityTiles.has(currentMouseTarget)):
						var targetedEntity = otherEntities[entityTiles.find(currentMouseTarget)]
						if(targetedEntity != self):
							viableTarget = true
							currentArcTargets.merge({target:targetedEntity})
		
		if(viableTarget):
			drawCurve()
		else:
			resetArc()

func drawCurve() -> void:
	var curve = arc.curve
	
	curve.set_point_position(0, tilemap.map_to_local(tilemap.local_to_map(global_position))-Vector2(32, 32))
	curve.set_point_position(1, tilemap.map_to_local(tilemap.local_to_map(get_global_mouse_position()))-Vector2(32, 32))
	
	setLinePointsToBezierCurve(arcLine, curve.get_point_position(0), curve.get_point_position(1),
								curve.get_point_out(0), curve.get_point_in(1))

func checkLineOfSight(pos) -> bool:
	ray.target_position = to_local(tilemap.map_to_local(tilemap.local_to_map(get_global_mouse_position())))
	var canSee = !ray.is_colliding()
	
	return canSee

func getArcTargets() -> Dictionary:
	return currentArcTargets

func enableLine() -> void:
	if currentPath.is_empty():
		updateImpassable()
		line.visible = true
		$ColorRect.color = "26cd00"

func disableLine() -> void:
	line.visible = false
	$ColorRect.color = "1a9900"

func enableArc() -> void:
	updateImpassable()
	resetArc()
	arc.visible = true

func disableArc() -> void:
	arc.visible = false

func pathToMouse() -> Array[Vector2i]:
	var idPath = []
	
	if moving:
		pass
	else:
		idPath = astarGrid.get_id_path(
			tilemap.local_to_map(global_position), 
			tilemap.local_to_map(get_global_mouse_position()))
	
	return idPath

func setPath(path = get_global_mouse_position()) -> void:
	super(path)

func setLinePointsToBezierCurve(line: Line2D, a: Vector2, b: Vector2, outA: Vector2, inB: Vector2) -> void:
	var curve := Curve2D.new()
	curve.add_point(a, Vector2.ZERO, outA)
	curve.add_point(b, inB, Vector2.ZERO)
	line.points = curve.get_baked_points()

func resetArc() -> void:
	arcLine.points = [Vector2(0, 0), Vector2(0, 0)]



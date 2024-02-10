extends RigidBody3D

var last_rotation : Vector3 = Vector3(0, 0, 0)
var last_location : Vector3 = Vector3(0, 0, 0)
var stable_count : float = 0

var value : int = 0
var velo : int = -1

var locked : bool = false
var sel : bool = false

signal entered
signal exited
signal clicked
signal doubleclicked

var colorRed : Color = Color(0.8, 0, 0, 1)
var colorRedHi : Color = Color(0.8, 0.5, 0.5, 1)

var colorBlue : Color = Color(0, 0, 0.8, 1)
var colorBlueHi : Color = Color(0.5, 0.5, 0.8, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var mat = $DiceModel/Cube.get_surface_override_material(1)
	var newmat = mat.duplicate()
	newmat.set_shader_parameter('Color', colorRed)
	$DiceModel/Cube.set_surface_override_material(1, newmat)
	pass
	
func _process(delta):

	if abs(velo - linear_velocity.length()) > 3 and velo >= 0:
		thud(abs(velo - linear_velocity.length()))
	velo = linear_velocity.length()
		
	if rotation == last_rotation:
		stable_count += delta
	else:
		last_rotation = rotation
		stable_count = 0
	if position == last_location:
		stable_count += delta
	else:
		last_location = position
		stable_count = 0


func is_stable() -> bool:
	return stable_count > 0.5

func set_value(v):
	value = v

func get_value() -> int:
	var basis = get_global_basis()
	var x = basis.x.y
	var y = basis.y.y
	var z = basis.z.y
	if abs(x) > abs(y) and abs(x) > abs(z):
		if (x > 0):
			return 4
		else:
			return 3
	if abs(y) > abs(x) and abs(y) > abs(z):
		if (y > 0):
			return 1
		else:
			return 6
	if abs(z) > abs(y) and abs(z) > abs(x):
		if (z > 0):
			return 5
		else:
			return 2
	return 0
	
func shake():
	if locked:
		return
	angular_velocity.x = randi() % 20 - 10
	angular_velocity.y = randi() % 20 - 10
	angular_velocity.z = randi() % 20 - 10
	apply_impulse(Vector3(randi() % 20 - 10, randi() % 40 + 10, randi() % 20 - 10))
	stable_count = 0

func nudge():
	if locked:
		return
	apply_impulse(Vector3(randi() % 10 - 5, randi() % 10 - 5, randi() % 10 - 5))
	stable_count = 0

func thud(vol : int = 20):
	if (vol > 30):
		vol = 30
	$AudioStreamPlayer3D.volume_db = -20 + vol
	$AudioStreamPlayer3D.play()



func _on__mouse_entered():
	entered.emit(self)
	if locked:
		$DiceModel/Cube.get_surface_override_material(1).set_shader_parameter('Color', colorBlueHi)
	else:
		$DiceModel/Cube.get_surface_override_material(1).set_shader_parameter('Color', colorRedHi)
	sel = true

func _on__mouse_exited():
	exited.emit(self)
	if locked:
		$DiceModel/Cube.get_surface_override_material(1).set_shader_parameter('Color', colorBlue)
	else:
		$DiceModel/Cube.get_surface_override_material(1).set_shader_parameter('Color', colorRed)
	sel = false

func _input(event):
	if sel:
		if event is InputEventMouseButton:
			if event.pressed:
				match event.button_index:
					1:
						if event.double_click:
							doubleclicked.emit(self)
						else:
							clicked.emit(self)
							locked = !locked
							if locked:
								$DiceModel/Cube.get_surface_override_material(1).set_shader_parameter('Color', colorBlueHi)
							else:
								$DiceModel/Cube.get_surface_override_material(1).set_shader_parameter('Color', colorRedHi)
					2:
						nudge()

extends Node3D

var DiceClass = preload("res://Dice.tscn")

var running = false

var camera_phi : float = PI
var zoom : int = 15
var focus_dice = -1
var current_look : Vector3 = Vector3(0, 0, 0)
var current_position : Vector3 = Vector3(0, 0, 0)

func _ready():
	for i in 6:
		add_dice()
	running = true
	$Label3D.text = "Rolling..."

func _process(delta):
	if running:
		var stable = 0
		for d in get_children():
			if (d is RigidBody3D):
				stable += 1
				if d.is_stable():
					stable -= 1
		if stable == 0:
			var vals : Array[int] = []
			for d in get_children():
				if (d is RigidBody3D):
					vals.push_back(d.get_value())
			vals.sort()
			var txt = ""
			var txt2 = ""
			for v in vals:
				if not txt == "":
					txt += " "
				txt += str(v)
				txt2 += str(v)
			$Label3D.text  = txt
			var l = Label.new()
			l.text = txt2
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			l.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
			l.theme_type_variation = "LogLabel"
			$LastContainer/Last.add_child(l)
			await(get_tree().process_frame)
			_scroll_panel()
			running = false

	var seld = select_dice(focus_dice)
	var target_look : Vector3 = Vector3(0, 0, 0)
	var target_position : Vector3 = Vector3(0, 0, 0)
	if seld != null:
		target_position = seld.position
		target_look = seld.position

	if current_look.x > target_look.x:
		current_look.x -= (current_look.x - target_look.x) / 0.1 * delta
	if current_look.x < target_look.x:
		current_look.x += (target_look.x - current_look.x) / 0.1 * delta
		
	if current_look.y > target_look.y:
		current_look.y -= (current_look.y - target_look.y) / 0.1 * delta
	if current_look.y < target_look.y:
		current_look.y += (target_look.y - current_look.y) / 0.1 * delta

	if current_look.z > target_look.z:
		current_look.z -= (current_look.z - target_look.z) / 0.1 * delta
	if current_look.z < target_look.z:
		current_look.z += (target_look.z - current_look.z) / 0.1 * delta
		

	if current_position.x > target_position.x:
		current_position.x -= (current_position.x - target_position.x) / 1.1 * delta
	if current_position.x < target_position.x:
		current_position.x += (target_position.x - current_position.x) / 1.1 * delta

	if current_position.z > target_position.z:
		current_position.z -= (current_position.z - target_position.z) / 1.1 * delta
	if current_position.z < target_position.z:
		current_position.z += (target_position.z - current_position.z) / 1.1 * delta


	if Input.is_key_pressed(KEY_LEFT):
		camera_phi -= delta

	if Input.is_key_pressed(KEY_RIGHT):
		camera_phi += delta


	$Camera.position.x = current_position.x + (sin(camera_phi) * zoom)
	$Camera.position.z = current_position.z + (cos(camera_phi) * zoom)
	$Camera.look_at(current_look)

func _scroll_panel():
	$LastContainer.scroll_vertical = $LastContainer.get_v_scroll_bar().max_value
	var kids = $LastContainer/Last.get_children()
	kids.reverse()
	var opacity : float = 1.0
	for kid in kids:
		kid.modulate.a = opacity
		opacity -= 0.1
		if (opacity < 0):
			opacity = 0

func _input(event):
	if event is InputEventMouseButton:
		print(event as InputEventMouseButton)
		match event.button_index:
			4:
				zoom -= 1
				if zoom < 5:
					zoom = 5
			5:
				zoom += 1
				if zoom > 30:
					zoom = 30
				
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				32: # Space
					roll()
				82: # R
					refresh()

				4194320:
					focus_dice += 1
					if select_dice(focus_dice) == null:
						focus_dice = -1

				4194322:
					focus_dice -= 1
					if focus_dice < -1:
						focus_dice = num_dice() - 1
				_:
					print(event.keycode)

func refresh():
	var num : int = 0
	for d in get_children():
		if d is RigidBody3D:
			num += 1
			remove_child(d)
			d.queue_free()
	for i in num: 
		add_dice()

func remove_dice():
	running = true
	for d in get_children():
		if d is RigidBody3D:
			remove_child(d)
			d.queue_free()
			return

func add_dice():
	running = true
	var d = DiceClass.instantiate()
	d.entered.connect(_on_dice_entered)
	d.exited.connect(_on_dice_exited)
	d.position.x = randi() % 20 - 10
	d.position.z = randi() % 20 - 10
	d.position.y = randi() % 5 + 15
	d.rotation.x = randf() * PI * 2
	d.rotation.y = randf() * PI * 2
	d.rotation.z = randf() * PI * 2
	d.angular_velocity.x = randi() % 20 - 10
	d.angular_velocity.y = randi() % 20 - 10
	d.angular_velocity.z = randi() % 20 - 10
	add_child(d)


func _on_roll_pressed():
	roll()

func roll():
	for d in get_children():
		if (d is RigidBody3D):
			d.shake()
	$Label3D.text = "Rolling..."
	running = true	

func _on_dice_entered(dice):
	$Val.text = str(dice.get_value())
	pass

func _on_dice_exited(dice):
	$Val.text = ""
	pass

func select_dice(num : int):
	var i : int = 0
	for kid in get_children():
		if kid is RigidBody3D:
			if i == num:
				return kid
			i += 1
	return null

func num_dice():
	return get_children().filter(func(x): return x is RigidBody3D).size()

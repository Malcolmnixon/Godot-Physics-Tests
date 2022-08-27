extends PhysicsUnitTest2D

var speed := 25000
var simulation_duration := 1

func test_description() -> String:
	return """Checks if the Continuous Collision Detection (CCD) is working, it must ensure that moving
	objects does not go through objects (tunnelling).
	"""
	
func test_name() -> String:
	return "RigidBody | testing Continuous Collision Detection (CCD)"

func start() -> void:
	var vertical_wall = get_static_body_with_collision_shape(Rect2(Vector2(0,0), Vector2(2, Global.WINDOW_SIZE.y/2)), PhysicsTest2D.TestCollisionShape.RECTANGLE, true)
	vertical_wall.position = Vector2(TOP_RIGHT.x - Global.WINDOW_SIZE.y/2 -1, 0)
	add_child(vertical_wall)
	
	var horizontal_wall = get_static_body_with_collision_shape(Rect2(Vector2(0,0), Vector2(Global.WINDOW_SIZE.y/2, 2)), PhysicsTest2D.TestCollisionShape.RECTANGLE, true)
	horizontal_wall.position = Vector2(BOTTOM_RIGHT.x - Global.WINDOW_SIZE.y/2, BOTTOM_RIGHT.y -50)
	add_child(horizontal_wall)
	
	var rigid_x_ccd_disabled = create_rigid_body(RigidBody2D.CCD_MODE_DISABLED)
	rigid_x_ccd_disabled.position = Vector2(50, 50)
	
	var rigid_x_ccd_ray = create_rigid_body(RigidBody2D.CCD_MODE_CAST_RAY)
	rigid_x_ccd_ray.position = Vector2(50, 150)
	
	var rigid_x_ccd_shape = create_rigid_body(RigidBody2D.CCD_MODE_CAST_SHAPE)
	rigid_x_ccd_shape.position = Vector2(50, 250)
	
	var rigid_y_ccd_disabled = create_rigid_body(RigidBody2D.CCD_MODE_DISABLED, false)
	rigid_y_ccd_disabled.position = Vector2(vertical_wall.position.x + 50, 50)
	
	var rigid_y_ccd_ray = create_rigid_body(RigidBody2D.CCD_MODE_CAST_RAY, false)
	rigid_y_ccd_ray.position = Vector2(vertical_wall.position.x + 150, 50)
	
	var rigid_y_ccd_shape = create_rigid_body(RigidBody2D.CCD_MODE_CAST_SHAPE, false)
	rigid_y_ccd_shape.position = Vector2(vertical_wall.position.x + 250, 50)
	
	var x_lambda = func(p_step, p_target, p_monitor):
		if p_target.continuous_cd == RigidBody2D.CCD_MODE_DISABLED:
			return p_target.position.x > vertical_wall.position.x # bad
		else:
			return p_target.position.x <= vertical_wall.position.x # good

	var y_lambda = func(p_step, p_target, p_monitor):
		if p_target.continuous_cd == RigidBody2D.CCD_MODE_DISABLED:
			return p_target.position.y > horizontal_wall.position.y # bad
		else:
			return p_target.position.y <= horizontal_wall.position.y # good
	
	var x_no_ccd_monitor = create_generic_expiration_monitor(rigid_x_ccd_disabled, x_lambda, null, simulation_duration)
	x_no_ccd_monitor.test_name = "Rigid moving in x without CCD pass through the wall"

	var x_ray_ccd_monitor = create_generic_expiration_monitor(rigid_x_ccd_ray, x_lambda, null, simulation_duration)
	x_ray_ccd_monitor.test_name = "Rigid moving in x without CCD Ray does not pass through the wall"
	
	var x_shape_ccd_monitor = create_generic_expiration_monitor(rigid_x_ccd_shape, x_lambda, null, simulation_duration)
	x_shape_ccd_monitor.test_name = "Rigid moving in x without CCD Cast shape does not pass through the wall"
	
	var y_no_ccd_monitor = create_generic_expiration_monitor(rigid_y_ccd_disabled, y_lambda, null, simulation_duration)
	y_no_ccd_monitor.test_name = "Rigid moving in y without CCD pass through the wall"

	var y_ray_ccd_monitor = create_generic_expiration_monitor(rigid_y_ccd_ray, y_lambda, null, simulation_duration)
	y_ray_ccd_monitor.test_name = "Rigid moving in y without CCD Ray does not pass through the wall"
	
	var y_shape_ccd_monitor = create_generic_expiration_monitor(rigid_y_ccd_shape, y_lambda, null, simulation_duration)
	y_shape_ccd_monitor.test_name = "Rigid moving in y without CCD Cast shape does not pass through the wall"
	
	process_mode = Node.PROCESS_MODE_DISABLED # to be able to see something
	await get_tree().create_timer(.5).timeout
	process_mode = Node.PROCESS_MODE_INHERIT

func create_rigid_body(p_ccd_mode: RigidBody2D.CCDMode, p_horizontal := true, p_shape: PhysicsTest2D.TestCollisionShape = TestCollisionShape.CIRCLE) -> RigidBody2D:
	var player = RigidBody2D.new()
	player.add_child(get_default_collision_shape(p_shape))
	player.gravity_scale = 0
	player.continuous_cd = p_ccd_mode
	var force = Vector2(speed, 0) if p_horizontal else Vector2(0, speed)
	player.apply_central_impulse(force)
	add_child(player)
	return player
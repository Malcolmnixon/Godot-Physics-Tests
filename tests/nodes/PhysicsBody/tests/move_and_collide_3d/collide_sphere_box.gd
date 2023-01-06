extends PhysicsUnitTest3D

# Tolerances
const POSITION_TOLERANCE := 0.01
const NORMAL_TOLERANCE := 0.005

var simulation_duration := 20
var test_failed := false

func test_description() -> String:
	return """Checks whether the move_and_collide between sphere and box works
	correctly."""
	
func test_name() -> String:
	return "PhysicsBody3D | testing collide sphere with box"

var tested_body: CharacterBody3D
var static_body: StaticBody3D

func test_start() -> void:
	tested_body = $Tested
	static_body = $Static
	
	var test_lambda: Callable = func(_p_target, p_monitor: GenericManualMonitor):
		# Get the test block and index
		var test_block := int(p_monitor.frame / 100.0)
		var test_index := int(p_monitor.frame % 100)

		# Get the test raster positions X/Y/Theta
		var r1 : float = floor(test_index / 10.0) - 5.0
		var r2 : float = (test_index % 10) - 5.0
		var rf : float = test_index / 10.0 - 5.0
		var ru : float = test_index / 100.0 

		# Pick the start position and move direction
		var start : Vector3
		var move : Vector3
		var position_expected : Vector3
		var normal_expected : Vector3
		match test_block:
			0:		# Collide from X+ direction
				start = Vector3(103, r1, r2)
				move = Vector3(-10, 0, 0)
				position_expected = Vector3(100, r1, r2)
				normal_expected = Vector3(1, 0, 0)

			1:		# Collide from X- direction
				start = Vector3(-103, r1, r2)
				move = Vector3(10, 0, 0)
				position_expected = Vector3(-100, r1, r2)
				normal_expected = Vector3(-1, 0, 0)

			2:		# Collide from Y+ direction
				start = Vector3(r1, 53, r2)
				move = Vector3(0, -10, 0)
				position_expected = Vector3(r1, 50, r2)
				normal_expected = Vector3(0, 1, 0)

			3:		# Collide from Y- direction
				start = Vector3(r1, -53, r2)
				move = Vector3(0, 10, 0)
				position_expected = Vector3(r1, -50, r2)
				normal_expected = Vector3(0, -1, 0)

			4:		# Collide from Z+ direction
				start = Vector3(r1, r2, 53)
				move = Vector3(0, 0, -10)
				position_expected = Vector3(r1, r2, 50)
				normal_expected = Vector3(0, 0, 1)

			5:		# Collide from Z- direction
				start = Vector3(r1, r2, -53)
				move = Vector3(0, 0, 10)
				position_expected = Vector3(r1, r2, -50)
				normal_expected = Vector3(0, 0, -1)

			6:		# Collide from XY+ edge
				start = Vector3(103, 53, rf)
				move = Vector3(-10, -10, 0)
				position_expected = Vector3(100, 50, rf)
				normal_expected = Vector3(0.707107, 0.707107, 0)

			7:		# Collide from XY- edge
				start = Vector3(-103, -53, rf)
				move = Vector3(10, 10, 0)
				position_expected = Vector3(-100, -50, rf)
				normal_expected = Vector3(-0.707107, -0.707107, 0)
				
			8:		# Collide from XYZ+
				start = Vector3(103 + ru * 5, 53 + ru * 5, 53 + ru * 5)
				move = Vector3(-10, -10, -10)
				position_expected = Vector3(100, 50, 50)
				normal_expected = Vector3(0.57735, 0.57735, 0.57735)
				
			_:		# End of test
				p_monitor.passed()
				return

		# Set the position and perform the move_and_collide
		tested_body.global_position = start
		var collision : KinematicCollision3D = tested_body.move_and_collide(move)
		if !collision:
			p_monitor.failed()
			return

		# Check the collision is on ths sphere
		var position_actual := collision.get_position()
		var position_error := position_expected.distance_to(position_actual)
		if position_error > POSITION_TOLERANCE:
			p_monitor.failed()
			return

		# Verify collision normal matches expected
		var normal_actual := collision.get_normal()
		var normal_error := normal_expected.distance_to(normal_actual)
		if normal_error > NORMAL_TOLERANCE:
			p_monitor.failed()
			return

	var collision_monitor := create_generic_manual_monitor(self, test_lambda, simulation_duration)
	collision_monitor.test_name = "move_and_collide for sphere and box are detected correctly"

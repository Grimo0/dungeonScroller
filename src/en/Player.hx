package en;

class Player extends Unit {

	var collisionThreshold = 0.25;

	public var isJumping = false;
	public var isCrouched = false;


	public function new(id : String) {
		maxLife = 1;

		super(id);
		
		frictY = 1.;
		dy = -0.01;
	}

	public function jump() {
		// TODO
	}

	public function crouch() {
		// TODO
	}

	override function postUpdate() {
		super.postUpdate();

		var x = cx;
		if (xr > 1 - collisionThreshold) x++;
		else if (xr < collisionThreshold) x--;
		var y = cy;
		if (yr < collisionThreshold) y--;

		if (!isJumping && level.getFloor(x, y) == 0) // No floor
			kill(null);
		if (!isCrouched && level.getCeiling(x, y) != 0) // Hit a ceiling
			kill(null);
	}

	override function onDie() {
		dy = 0;
	}
}
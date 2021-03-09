package en;

import haxe.Exception;

class Player extends Unit {
	var collisionThreshold = 0.25;

	public var isJumping = false;
	public var isCrouched = false;

	public function new(id : String) {
		maxLife = 1;

		super(id);

		frictY = 1.;

		if (game.player != null && !game.player.destroyed)
			throw new Exception("Trying to create a second player entity");
		game.player = this;
	}

	override function dispose() {
		super.dispose();
		if (game.player == this)
			game.player = null;
	}

	public function jump() {
		if (isJumping || isCrouched) return;
		isJumping = true;
		final timeToAir = 0.1;
		final dist = 1.5;
		game.tw.createS(sprScale, 1.2, timeToAir).onEnd = () -> {
			cd.setF('jump', dist / M.fabs(dy), () -> {
				game.tw.createS(sprScale, 1, timeToAir).onEnd = () -> { isJumping = false; }
			});
		};
	}

	public function crouch() {
		if (isJumping) return;
		isCrouched = true;
		final timeToGround = 0.1;
		final dist = 1.5;
		game.tw.createS(sprScale, 0.8, timeToGround).onEnd = () -> {
			cd.setF('crouch', dist / M.fabs(dy), () -> {
				game.tw.createS(sprScale, 1, timeToGround).onEnd = () -> { isCrouched = false; }
			});
		};
	}

	override function postUpdate() {
		super.postUpdate();

		var x = cx;
		if (xr > 1 - collisionThreshold)
			x++;
		else if (xr < collisionThreshold)
			x--;
		var y = cy;
		if (yr < collisionThreshold)
			y--;

		if (!isJumping && level.getFloor(cx, cy) == 0) // No floor
			kill(null);
		if (!isCrouched && level.getCeiling(x, y) != 0) // Hit a ceiling
			kill(null);
	}

	override function onDie() {
		cancelVelocities();
	}
}

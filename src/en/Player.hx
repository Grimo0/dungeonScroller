package en;

import haxe.Exception;

class Player extends Unit {
	var ceilingRadius = 0.35;

	var strideSpeed = 0.5;
	var strideMvt = 0.;

	var shadowFilter : h2d.filter.DropShadow;

	public var isJumping = false;
	public var isCrouched = false;
	public var height(default, set) = 1.;
	public function set_height(h : Float) {
		sprScaleX = sprScaleY = 0.6 + 0.4 * h;
		shadowFilter.alpha = 0.25 + Math.pow(0.25, h);
		shadowFilter.distance = 2 + h * 4;
		return height = h;
	}

	public function new(id : String) {
		maxLife = 1;

		super(id);

		hei = game.level.gridSize * 0.5;
		radius = 0.5 * hei;
		frictX = 1.;
		frictY = 1.;

		shadowFilter = new h2d.filter.DropShadow(6, M.PIHALF, 0, 0.5, 20, true);
		spr.filter = shadowFilter;
		height = 1.;

		if (game.player != null && !game.player.destroyed)
			throw new Exception("Trying to create a second player entity");
		game.player = this;
	}

	override function dispose() {
		super.dispose();
		if (game.player == this)
			game.player = null;
	}

	public function left() {
		dx = -strideSpeed;
		strideMvt = -1.;
	}

	public function right() {
		dx = strideSpeed;
		strideMvt = 1.;
	}

	public function jump() {
		if (isJumping || isCrouched) return;
		isJumping = true;
		final dist = 1.5;
		final totalTime = dist / M.fabs(dy);
		final timeToAir = 0.2 * Options.ME.speedMul;
		game.tw.createS(height, 1.5, TType.TEaseOut, timeToAir).onEnd = () -> {
			cd.setF('jump', totalTime - 2 * timeToAir, () -> {
				game.tw.createS(height, 1., TType.TEaseIn, timeToAir).onEnd = () -> isJumping = false;
			});
		};
	}

	public function crouch() {
		if (isJumping) return;
		isCrouched = true;

		var dist = 0.;
		var x = cx;
		var y = cy;
		var ceilingThreshold = ceilingRadius - radius / game.level.gridSize;
		if (xr > 1 - ceilingThreshold) x++;
		else if (xr < ceilingThreshold) x--;
		if (yr < ceilingThreshold) {
			y--;
			dist = 1. - yr;
		} else 
			dist = yr - ceilingThreshold;
		while (level.getCeiling(x, --y) != 0) {
			dist++;
		}
		if (dist < 1.) dist = 1.;

		final totalTime = dist / M.fabs(dy);
		final timeToGround = 0.2 * Options.ME.speedMul;
		game.tw.createS(height, 0.5, TType.TEaseIn, timeToGround).onEnd = () -> {
			cd.setF('crouch', totalTime - 2 * timeToGround, () -> {
				game.tw.createS(height, 1., TType.TEaseOut, timeToGround).onEnd = () -> isCrouched = false;
			});
		};
	}

	public function reachedEnd() {
		frictX = 0.9;
		frictY = 0.9;
		game.camera.stopTracking();

		game.reachedEnd();
	}

	override function update() {
		super.update();

		// Stride movement
		if (strideMvt < 0) {
			if (cx + xr - prevFrameCXR < strideMvt) {
				xr -= cx + xr - prevFrameCXR - strideMvt;
				while (xr > 1) {
					xr--;
					cx++;
				}
				dx = 0;
			}
			strideMvt -= cx + xr - prevFrameCXR;
		} else if (strideMvt > 0) {
			if (cx + xr - prevFrameCXR > strideMvt) {
				xr -= cx + xr - prevFrameCXR - strideMvt;
				while (xr < 0) {
					xr++;
					cx--;
				}
				dx = 0;
			}
			strideMvt -= cx + xr - prevFrameCXR;
		}
	}

	override function postUpdate() {
		super.postUpdate();

		// End tile !
		if (!isJumping && level.getFloor(cx, cy) == 2) {
			reachedEnd();
			return;
		}

		// No floor
		if (!isJumping && level.getFloor(cx, cy) == 0) {
			kill(null);
			return;
		}

		// Hit a ceiling
		var x = cx;
		var y = cy;
		var ceilingThreshold = ceilingRadius - radius / game.level.gridSize;
		if (xr > 1 - ceilingThreshold) x++;
		else if (xr < ceilingThreshold) x--;
		if (yr < ceilingThreshold) y--;
		
		if (!isCrouched && level.getCeiling(x, y) != 0) {
			kill(null);
			return;
		}
	}

	override function onDie() {
		cancelVelocities();
	}
}

import en.Entity;

class Camera extends dn.Process {
	public var target : Null<Entity>;
	public var x : Float;
	public var y : Float;
	public var dx : Float;
	public var dy : Float;
	public var wid(get, never) : Int;
	function get_wid() return M.ceil(Game.ME.w() / Const.SCALE);
	public var hei(get, never) : Int;
	function get_hei() return M.ceil(Game.ME.h() / Const.SCALE);

	public var frict = 0.89;
	public var targetS = 0.006;
	public var targetDeadZone = 5;

	var bumpOffX = 0.;
	var bumpOffY = 0.;

	var shakePower = 1.0;

	public function new() {
		super(Game.ME);
		x = y = 0;
		dx = dy = 0;
	}

	public function trackTarget(e : Entity, immediate : Bool) {
		target = e;
		if (immediate)
			recenter();
	}

	public inline function stopTracking() {
		target = null;
	}

	public function recenter() {
		if (target != null) {
			x = target.headX;
			y = target.headY;
		}
	}

	public inline function scrollerToGlobalX(v : Float)
		return v * Const.SCALE + Game.ME.scroller.x;

	public inline function scrollerToGlobalY(v : Float)
		return v * Const.SCALE + Game.ME.scroller.y;

	public function shakeS(t : Float, ?pow = 1.0) {
		cd.setS("shaking", t, false);
		shakePower = pow;
	}

	override function update() {
		super.update();

		// Follow target entity
		if (target != null) {
			var tx = target.headX;
			var ty = target.headY;

			var d = M.dist(x, y, tx, ty);
			if (d >= targetDeadZone) {
				var a = Math.atan2(ty - y, tx - x);
				dx += Math.cos(a) * (d - targetDeadZone) * targetS * tmod;
				dy += Math.sin(a) * (d - targetDeadZone) * targetS * tmod;
			}
		}

		x += dx * tmod;
		dx *= Math.pow(frict, tmod);

		y += dy * tmod;
		dy *= Math.pow(frict, tmod);
	}

	public inline function bumpAng(a, dist) {
		bumpOffX += Math.cos(a) * dist;
		bumpOffY += Math.sin(a) * dist;
	}

	public inline function bump(x, y) {
		bumpOffX += x;
		bumpOffY += y;
	}

	override function postUpdate() {
		super.postUpdate();

		if (!ui.Console.ME.hasFlag("scroll")) {
			var level = Game.ME.level;
			var scroller = Game.ME.scroller;

			// Update scroller
			if (wid < level.wid)
				scroller.x = M.fclamp(-x + wid * 0.5, wid - level.wid, 0);
			else if (level.wid != 0)
				scroller.x = wid * 0.5 - level.wid * 0.5;
			else
				scroller.x = - level.wid * 0.5;
			if (hei < level.hei)
				scroller.y = M.fclamp(-y + hei * 0.5, hei - level.hei, 0);
			else if (level.hei != 0)
				scroller.y = hei * 0.5 - level.hei * 0.5;
			else
				scroller.y = - level.hei * 0.5;

			// Bumps friction
			bumpOffX *= Math.pow(0.75, tmod);
			bumpOffY *= Math.pow(0.75, tmod);

			// Bump
			scroller.x += bumpOffX;
			scroller.y += bumpOffY;

			// Shakes
			if (cd.has("shaking")) {
				scroller.x += Math.cos(ftime * 1.1) * 2.5 * shakePower * cd.getRatio("shaking");
				scroller.y += Math.sin(0.3 + ftime * 1.7) * 2.5 * shakePower * cd.getRatio("shaking");
			}

			// Scaling
			scroller.x *= Const.SCALE;
			scroller.y *= Const.SCALE;

			// Rounding
			scroller.x = M.round(scroller.x);
			scroller.y = M.round(scroller.y);
		}
	}
}

package en;

class Entity {
	public static var ALL : Array<Entity> = [];
	public static var GC : Array<Entity> = [];

	// Shorthands properties
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;
	public var fx(get, never) : Fx;
	inline function get_fx() return Game.ME.fx;
	public var level(get, never) : Level;
	inline function get_level() return Game.ME.level;
	public var ftime(get, never) : Float;
	inline function get_ftime() return Game.ME.ftime;
	public var utmod(get, never) : Float;
	inline function get_utmod() return Game.ME.utmod;
	public var tmod(get, never) : Float;
	inline function get_tmod() return Game.ME.tmod;
	public var hud(get, never) : ui.Hud;
	inline function get_hud() return Game.ME.hud;

	// Main properties
	public var uid : Int;

	public var destroyed(default, null) = false;

	public var cd : dn.Cooldown;
	public var ucd : dn.Cooldown;

	// Base coordinates
	public var cx = 0;
	public var cy = 0;
	public var xr = 0.5;
	public var yr = 0.5;
	public var hei(default, set) : Float = game.level.gridSize;
	inline function set_hei(v) {
		invalidateDebugBounds = true;
		return hei = v;
	}
	public var radius(default, set) = game.level.gridSize * 0.5;
	inline function set_radius(v) {
		invalidateDebugBounds = true;
		return radius = v;
	}

	// Movements
	public var dx = 0.;
	public var dy = 0.;
	public var bdx = 0.;
	public var bdy = 0.;
	public var dxTotal(get, never) : Float;
	inline function get_dxTotal() return dx + bdx;
	public var dyTotal(get, never) : Float;
	inline function get_dyTotal() return dy + bdy;

	public var frictX = 0.82;
	public var frictY = 0.82;
	public var bumpFrict = 0.93;

	public var footX(get, never) : Float;
	inline function get_footX() return centerX;
	public var footY(get, never) : Float;
	inline function get_footY() return centerY + 0.5 * hei;
	public var headX(get, never) : Float;
	inline function get_headX() return footX;
	public var headY(get, never) : Float;
	inline function get_headY() return footY - hei;
	public var centerX(get, never) : Float;
	inline function get_centerX() return (cx + xr) * game.level.gridSize;
	public var centerY(get, never) : Float;
	inline function get_centerY() return (cy + yr) * game.level.gridSize;
	public var prevFrameCXR : Float = -Const.INFINITE;
	public var prevFrameCYR : Float = -Const.INFINITE;

	// Display
	public var spr : HSprite;
	public var baseColor : h3d.Vector;
	public var blinkColor : h3d.Vector;
	public var colorMatrix : h3d.Matrix;
	public var sprScaleX = 1.0;
	public var sprScaleY = 1.0;
	public var sprSquashX = 1.0;
	public var sprSquashY = 1.0;
	public var visible = true;

	var actions : Array<{id : String, cb : Void->Void, t : Float}> = [];

	// Debug
	var debugLabel : Null<h2d.Text>;
	var debugBounds : Null<h2d.Graphics>;
	var invalidateDebugBounds = false;

	public function new(?sprLib:SpriteLib, ?x : Int, ?y : Int) {
		uid = Const.NEXT_UNIQ;
		ALL.push(this);

		cd = new dn.Cooldown(Const.FPS);
		ucd = new dn.Cooldown(Const.FPS);

		if (x != null && y != null)
			setPosCell(x, y);

		spr = new HSprite(sprLib);
		game.level.root.add(spr, Const.GAME_LEVEL_ENTITIES);
		spr.colorAdd = new h3d.Vector();
		baseColor = new h3d.Vector();
		blinkColor = new h3d.Vector();
		spr.colorMatrix = colorMatrix = h3d.Matrix.I();
		spr.setCenterRatio(0.5, 0.5);

		if (ui.Console.ME.hasFlag("bounds"))
			enableBounds();
	}

	public function setPosCell(x : Int, y : Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 0.5;
		onPosManuallyChanged();
	}

	public function setPosPixel(x : Float, y : Float) {
		cx = Std.int(x / game.level.gridSize);
		cy = Std.int(y / game.level.gridSize);
		xr = (x - cx * game.level.gridSize) / game.level.gridSize;
		yr = (y - cy * game.level.gridSize) / game.level.gridSize;
		onPosManuallyChanged();
	}

	function onPosManuallyChanged() {
		if (M.dist(cx + xr, cy + yr, prevFrameCXR, prevFrameCYR) > 2.) {
			prevFrameCXR = cx + xr;
			prevFrameCYR = cy + yr;
		}
	}

	public function bump(x : Float, y : Float) {
		bdx += x;
		bdy += y;
	}

	public function cancelVelocities() {
		dx = bdx = 0;
		dy = bdy = 0;
	}

	public function is<T : Entity>(c : Class<T>) return Std.isOfType(this, c);

	public function as<T : Entity>(c : Class<T>) : T return Std.downcast(this, c);

	public inline function dirTo(e : Entity) return e.centerX < centerX ? -1 : 1;

	public inline function getMoveAng() return Math.atan2(dyTotal, dxTotal);

	public inline function distEntity(e : Entity)
		return M.dist(cx + xr, cy + yr, e.cx + e.xr, e.cy + e.yr);

	public inline function distCell(tcx : Int, tcy : Int, ?txr = 0.5, ?tyr = 0.5)
		return M.dist(cx + xr, cy + yr, tcx + txr, tcy + tyr);

	public inline function distPx(e : Entity)
		return M.dist(footX, footY, e.footX, e.footY);

	public inline function distPxFree(x : Float, y : Float)
		return M.dist(footX, footY, x, y);

	public inline function destroy() {
		if (!destroyed) {
			destroyed = true;
			GC.push(this);
		}
	}

	public function dispose() {
		ALL.remove(this);

		baseColor = null;
		blinkColor = null;
		colorMatrix = null;

		spr.remove();
		spr = null;

		if (debugLabel != null) {
			debugLabel.remove();
			debugLabel = null;
		}

		if (debugBounds != null) {
			debugBounds.remove();
			debugBounds = null;
		}

		cd.destroy();
		cd = null;
	}

	public inline function debug(?v : Dynamic, ?c = 0xffffff) {
		#if debug
		if (v == null && debugLabel != null) {
			debugLabel.remove();
			debugLabel = null;
		}
		if (v != null) {
			if (debugLabel == null) {
				debugLabel = new h2d.Text(Assets.fontTiny);
				game.level.root.add(debugLabel, Const.GAME_LEVEL_TOP);
			}
			debugLabel.text = Std.string(v);
			debugLabel.textColor = c;
		}
		#end
	}

	public function disableBounds() {
		if (debugBounds != null) {
			debugBounds.remove();
			debugBounds = null;
		}
	}

	public function enableBounds() {
		if (debugBounds == null) {
			debugBounds = new h2d.Graphics();
			game.level.root.add(debugBounds, Const.GAME_LEVEL_TOP);
		}
		invalidateDebugBounds = true;
	}

	function renderBounds() {
		var c = Color.makeColorHsl((uid % 20) / 20, 1, 1);
		debugBounds.clear();

		// Radius
		debugBounds.lineStyle(1, c, 0.8);
		debugBounds.drawCircle(0, -radius, radius);

		// Hei
		debugBounds.lineStyle(1, c, 0.5);
		debugBounds.drawRect(-radius, -hei, radius * 2, hei);

		// Feet
		debugBounds.lineStyle(1, 0xffffff, 1);
		var d = game.level.gridSize * 0.2;
		debugBounds.moveTo(-d, 0);
		debugBounds.lineTo(d, 0);
		debugBounds.moveTo(0, -d);
		debugBounds.lineTo(0, 0);

		// Center
		debugBounds.lineStyle(1, c, 0.3);
		debugBounds.drawCircle(0, -hei * 0.5, 3);

		// Head
		debugBounds.lineStyle(1, c, 0.3);
		debugBounds.drawCircle(0, headY - footY, 3);
	}

	function chargeAction(id : String, sec : Float, cb : Void->Void) {
		if (isChargingAction(id))
			cancelAction(id);
		if (sec <= 0)
			cb();
		else
			actions.push({id: id, cb: cb, t: sec});
	}

	public function isChargingAction(?id : String) {
		if (id == null)
			return actions.length > 0;

		for (a in actions)
			if (a.id == id)
				return true;

		return false;
	}

	public function cancelAction(?id : String) {
		if (id == null)
			actions = [];
		else {
			var i = 0;
			while (i < actions.length) {
				if (actions[i].id == id)
					actions.splice(i, 1);
				else
					i++;
			}
		}
	}

	function updateActions() {
		var i = 0;
		while (i < actions.length) {
			var a = actions[i];
			a.t -= tmod / Const.FPS;
			if (a.t <= 0) {
				actions.splice(i, 1);
				if (!destroyed)
					a.cb();
			} else
				i++;
		}
	}

	public function blink(c : UInt) {
		blinkColor.setColor(c);
		cd.setS("keepBlink", 0.06);
	}

	public function setSquashX(v : Float) {
		sprSquashX = v;
		sprSquashY = 2 - v;
	}

	public function setSquashY(v : Float) {
		sprSquashX = 2 - v;
		sprSquashY = v;
	}

	public function preUpdate() {
		ucd.update(utmod);
		cd.update(tmod);
		updateActions();
	}

	public function postUpdate() {
		spr.x = (cx + xr) * game.level.gridSize;
		spr.y = (cy + yr) * game.level.gridSize;
		spr.scaleX = sprScaleX * sprSquashX;
		spr.scaleY = sprScaleY * sprSquashY;
		spr.visible = visible;

		sprSquashX += (1 - sprSquashX) * 0.2;
		sprSquashY += (1 - sprSquashY) * 0.2;

		// Blink
		if (!cd.has("keepBlink")) {
			blinkColor.r *= Math.pow(0.60, tmod);
			blinkColor.g *= Math.pow(0.55, tmod);
			blinkColor.b *= Math.pow(0.50, tmod);
		}

		// Color adds
		spr.colorAdd.load(baseColor);
		spr.colorAdd.r += blinkColor.r;
		spr.colorAdd.g += blinkColor.g;
		spr.colorAdd.b += blinkColor.b;

		// Debug label
		if (debugLabel != null) {
			debugLabel.x = Std.int(footX - debugLabel.textWidth * 0.5);
			debugLabel.y = Std.int(footY + 1);
		}

		// Debug bounds
		if (debugBounds != null) {
			if (invalidateDebugBounds) {
				invalidateDebugBounds = false;
				renderBounds();
			}
			debugBounds.x = footX;
			debugBounds.y = footY;
		}
	}

	public function finalUpdate() {
		prevFrameCXR = cx + xr;
		prevFrameCYR = cy + yr;
	}

	public function fixedUpdate() {}

	public function update() {
		// X
		var steps = M.ceil(M.fabs(dxTotal * tmod));
		var step = dxTotal * tmod / steps;
		while (steps > 0) {
			xr += step;

			// [ TODO add X collisions checks here ]

			while (xr > 1) {
				xr--;
				cx++;
			}
			while (xr < 0) {
				xr++;
				cx--;
			}
			steps--;
		}
		dx *= Math.pow(frictX, tmod);
		bdx *= Math.pow(bumpFrict, tmod);
		if (M.fabs(dx) <= 0.0005 * tmod)
			dx = 0;
		if (M.fabs(bdx) <= 0.0005 * tmod)
			bdx = 0;

		// Y
		var steps = M.ceil(M.fabs(dyTotal * tmod));
		var step = dyTotal * tmod / steps;
		while (steps > 0) {
			yr += step;

			// [ TODO add Y collisions checks here ]

			while (yr > 1) {
				yr--;
				cy++;
			}
			while (yr < 0) {
				yr++;
				cy--;
			}
			steps--;
		}
		dy *= Math.pow(frictY, tmod);
		bdy *= Math.pow(bumpFrict, tmod);
		if (M.fabs(dy) <= 0.0005 * tmod)
			dy = 0;
		if (M.fabs(bdy) <= 0.0005 * tmod)
			bdy = 0;

		#if debug
		if (ui.Console.ME.hasFlag("bounds") && debugBounds == null)
			enableBounds();

		if (!ui.Console.ME.hasFlag("bounds") && debugBounds != null)
			disableBounds();
		#end
	}
}

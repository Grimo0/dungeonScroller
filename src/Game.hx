import imgui.ImGui;
import en.Entity;
import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	public var ca : dn.heaps.Controller.ControllerAccess;
	public var fx : Fx;
	public var camera : Camera;
	public var scroller : h2d.Layers;
	public var level : Level;
	public var hud : ui.Hud;

	var curGameSpeed = 1.0;
	var slowMos : Map<String, {id : String, t : Float, f : Float}> = new Map();

	public var locked = false;

	var sav : GameSave = new GameSave();
	
	var flags : Map<String, Int> = new Map();

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.MAIN_LAYER_GAME);

		scroller = new h2d.Layers();
		root.add(scroller, Const.GAME_SCROLLER);
		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		camera = new Camera();
		level = new Level();
		fx = new Fx();
		hud = new ui.Hud();

		Process.resizeAll();

		root.alpha = 0;
		startLevel();
		tw.createS(root.alpha, 1, #if debug 0 #else 1 #end);
	}

	public function load() {
		sav = hxd.Save.load(sav, 'save/game');

		flags = sav.flags.copy();
	}

	public function save() {
		sav.flags = flags.copy();
		sav.levelUID = level.uniqId;

		hxd.Save.save(sav, 'save/game');
	}

	public inline function setFlag(k : String, ?v = 1) flags.set(k, v);

	public inline function unsetFlag(k : String) flags.remove(k);

	public inline function hasFlag(k : String) return getFlag(k) != 0;

	public inline function getFlag(k : String) {
		var f = flags.get(k);
		return f != null ? f : 0;
	}

	function startLevel(?levelUID : Int) {
		locked = false;

		scroller.removeChildren();

		level.currLevel = Assets.world.getLevel(levelUID != null ? levelUID : sav.levelUID);

		Process.resizeAll();
	}

	public function transition(levelUID : Null<Int>, event : String = null, ?onDone : Void->Void) {
		locked = true;

		tw.createS(root.alpha, 0, #if debug 0 #else 1 #end).onEnd = function() {
			if (levelUID == null) {
				save();
				
				Main.ME.startMainMenu();
			} else {
				startLevel(levelUID);

				var level = Assets.world.getLevel(levelUID);
				flags.set(level.identifier, 1);
				save();

				tw.createS(root.alpha, 1, #if debug 0 #else 1 #end);
			}

			if (onDone != null)
				onDone();
		}
	}

	public function onCdbReload() {}

	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);
	}

	override function onDispose() {
		super.onDispose();

		fx.destroy();
		for (e in Entity.ALL)
			e.destroy();
		gc();
	}

	function gc() {
		if (Entity.GC == null || Entity.GC.length == 0)
			return;

		for (e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	public function addSlowMo(id : String, sec : Float, speedFactor = 0.3) {
		if (slowMos.exists(id)) {
			var s = slowMos.get(id);
			s.f = speedFactor;
			s.t = M.fmax(s.t, sec);
		} else
			slowMos.set(id, {id: id, t: sec, f: speedFactor});
	}

	function updateSlowMos() {
		// Timeout active slow-mos
		for (s in slowMos) {
			s.t -= utmod * 1 / Const.FPS;
			if (s.t <= 0)
				slowMos.remove(s.id);
		}

		// Update game speed
		var targetGameSpeed = 1.0;
		for (s in slowMos)
			targetGameSpeed *= s.f;
		curGameSpeed += (targetGameSpeed - curGameSpeed) * (targetGameSpeed > curGameSpeed ? 0.2 : 0.6);

		if (M.fabs(curGameSpeed - targetGameSpeed) <= 0.001)
			curGameSpeed = targetGameSpeed;
	}

	public inline function stopFrame() {
		ucd.setS("stopFrame", 0.2);
	}

	override function preUpdate() {
		super.preUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.preUpdate();
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.fixedUpdate();
	}

	override function update() {
		super.update();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.update();

		#if debug
		if (Main.ME.debug) {
			updateImGui();
		}
		#end

		if (!ui.Console.ME.isActive() && !ui.Modal.hasAny()) {
			#if hl
			// Exit
			if (ca.isKeyboardPressed(Key.ESCAPE)) {
				if (!cd.hasSetS("exitWarn", 3)) {}
				else
					return Main.ME.startMainMenu();
			}
			#end

			// Restart
			if (ca.selectPressed())
				Main.ME.startGame();
		}
	}

	function updateImGui() {
		var scenes = Assets.world.levels;
		ImGui.comboWithArrow('currScene', Assets.world.levels.indexOf(level.currLevel), scenes,
			(i : Int) -> Assets.world.levels[i].identifier,
			(i : Int) -> transition(Assets.world.levels[i].uid)
		);
		ImGui.separator();
	}

	override function postUpdate() {
		super.postUpdate();

		for (e in Entity.ALL)
			if (!e.destroyed)
				e.postUpdate();
		for (e in Entity.ALL)
			if (!e.destroyed)
				e.finalUpdate();
		gc();

		// Update slow-motions
		updateSlowMos();
		setTimeMultiplier((0.2 + 0.8 * curGameSpeed) * (ucd.has("stopFrame") ? 0.3 : 1));
	}
}

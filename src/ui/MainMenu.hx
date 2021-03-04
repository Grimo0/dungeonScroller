package ui;

import dn.Process;

class MainMenu extends Process {
	public static var ME : MainMenu;

	public var ca(default, null) : dn.heaps.Controller.ControllerAccess;

	public function new() {
		super(Main.ME);
		ME = this;

		ca = Main.ME.controllers[0].createAccess("mainMenu");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);

		createRootInLayers(Main.ME.root, Const.MAIN_LAYER_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		Process.resizeAll();
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}

	override function update() {
		super.update();

		// Exit
		if (ca.bPressed()) {
			#if hl
			if (!cd.hasSetS("exitWarn", 3))
				trace(Lang.t._("Press ESCAPE again to exit."));
			else
				hxd.System.exit();
			#end

			return;
		}
	}
}

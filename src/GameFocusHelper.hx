import dn.Process;

class GameFocusHelper extends dn.heaps.GameFocusHelper {
	public function new() {
		super(Boot.ME.s2d, Assets.fontMedium);
	}

	override function suspendGame() {
		if (Game.ME != null && !Game.ME.isPaused() && Game.ME.started) {
			if (suspended)
				return;

			suspended = true;
			dn.heaps.slib.SpriteLib.DISABLE_ANIM_UPDATES = true;

			// Pause other process
			for (p in Process.ROOTS)
				if (p != this)
					p.pause();

			// Create mask
			root.visible = true;
			root.removeChildren();

			var bg = new h2d.Bitmap(h2d.Tile.fromColor(showIntro ? 0x252e43 : 0x0, 1, 1, showIntro ? 1 : 0.6), root);
			var i = new h2d.Interactive(1, 1, root);

			var tf = new h2d.Text(font, root);
			if (showIntro)
				tf.text = Lang.t._("Click anywhere to start");
			else
				tf.text = Lang.t._("PAUSED - click anywhere to resume");

			createChildProcess(
				function(c) {
					// Resize dynamically
					tf.setScale(M.imax(1, Math.floor(w() * 0.35 / tf.textWidth)));
					tf.x = Std.int(w() * 0.5 - tf.textWidth * tf.scaleX * 0.5);
					tf.y = Std.int(h() * 0.5 - tf.textHeight * tf.scaleY * 0.5);

					i.width = w() + 1;
					i.height = h() + 1;
					bg.scaleX = w() + 1;
					bg.scaleY = h() + 1;

					// Auto-kill
					if (!suspended)
						c.destroy();
				}, true
			);

			var loadingMsg = showIntro;
			i.onPush = function(_) {
				if (loadingMsg) {
					tf.text = Lang.t._("Loading, please wait...");
					tf.x = Std.int(w() * 0.5 - tf.textWidth * tf.scaleX * 0.5);
					tf.y = Std.int(h() * 0.5 - tf.textHeight * tf.scaleY * 0.5);
					delayer.addS(resumeGame, 1);
				} else
					resumeGame();
				i.remove();
			}

			showIntro = false;
		}
	}
}

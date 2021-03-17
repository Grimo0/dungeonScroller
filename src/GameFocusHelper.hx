

class GameFocusHelper extends dn.heaps.GameFocusHelper {

	public function new() {
		super(Boot.ME.s2d, Assets.fontMedium);
	}

	override function suspendGame() {
		if (Game.ME != null && !Game.ME.isPaused())
			super.suspendGame();
	}
}
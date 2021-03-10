import dn.Process;

enum EPlayerActions {
	left;
	right;
	jump;
	crouch;
}

class PlayerControl extends Process {

	var ca : dn.heaps.Controller.ControllerAccess;
	var controls = new Map<dn.heaps.GamePad.PadKey, EPlayerActions>();

	public function new(ca : dn.heaps.Controller.ControllerAccess) {
		super(Game.ME);
		this.ca = ca;
	}

	public function reset() {
		controls.clear();
	}

	public function add(key : dn.heaps.GamePad.PadKey, action : EPlayerActions) {
		controls.set(key, action);
	}

	override function update() {
		if (Game.ME.player.isDead() || Game.ME.locked || !Game.ME.started) return;
		
		for (key => action in controls) {
			if (ca.isPressed(key)) {
				switch action {
					case left: Game.ME.player.cx--;
					case right: Game.ME.player.cx++;
					case jump: Game.ME.player.jump();
					case crouch: Game.ME.player.crouch();
				}
			}
		}
	}
}
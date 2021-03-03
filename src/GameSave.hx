class GameSave {
	public var flags : Map<String, Int>;
	public var levelUID : Int;

	public function new() {
		flags = new Map();
		levelUID = Assets.world.levels[0].uid;
		flags.set(Assets.world.levels[0].identifier, 1);
	}
}
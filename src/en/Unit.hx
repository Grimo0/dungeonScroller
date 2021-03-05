package en;

class Unit extends Entity {
	public var id(default, null) : String;

	public var maxLife(default, null) : Int;
	public var life(default, set) : Int;
	public function set_life(v : Int) {
		final maxHP = maxLife;
		if (v > maxHP)
			return life = Std.int(maxHP);
		return life = v;
	}

	public var lastDmgSource(default, null) : Null<Entity> = null;
	public var lastHitDirFromSource(get, never) : Int;
	inline function get_lastHitDirFromSource()
		return lastDmgSource == null ? -dir : -dirTo(lastDmgSource);
	public var lastHitDirToSource(get, never) : Int;
	inline function get_lastHitDirToSource()
		return lastDmgSource == null ? dir : dirTo(lastDmgSource);

	public function new(id : String) {
		super();
		this.id = id;

		reset();
	}

	public function reset() {
		life = maxLife;
	}

	public inline function isDead() {
		return life <= 0;
	}

	public function hit(dmg : Int, from : Null<Entity>) {
		if (isDead() || dmg <= 0)
			return;

		life = M.iclamp(life - dmg, 0, Std.int(maxLife));
		lastDmgSource = from;
		onDamage(dmg, from);
		if (life <= 0)
			onDie();
	}

	public function kill(by : Null<Entity>) {
		if (!isDead())
			hit(life, by);
	}

	function onDamage(dmg : Int, from : Entity) {}

	function onDie() {
		destroy();
	}
}

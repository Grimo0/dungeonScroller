class Level extends dn.Process {
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;

	public var fx(get, never) : Fx;
	inline function get_fx() return game.fx;

	public var wid(get, never) : Int;
	inline function get_wid() return 10; // FIXME: level cells per row

	public var hei(get, never) : Int;
	inline function get_hei() return 10; // FIXME: level cells per column

	public function new() {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
	}

	public inline function isValid(cx, cy)
		return cx >= 0 && cx < wid && cy >= 0 && cy < hei;

	public inline function coordId(cx, cy)
		return cx + cy * wid;

	public inline function hasCollision(cx, cy) : Bool
		return false; // TODO: collision with entities and obstacles

	public function render() {
	}

	override function postUpdate() {
		super.postUpdate();

		render();
	}
}

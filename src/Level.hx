class Level extends dn.Process {
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;
	public var fx(get, never) : Fx;
	inline function get_fx() return game.fx;

	public var currLevel(default, set) : LDtkMap.LDtkMap_Level; // FIXME: Replace with your data level type
	public function set_currLevel(l : LDtkMap.LDtkMap_Level) {
		currLevel = l;
		initLevel();
		return currLevel;
	}

	public var wid(get, never) : Int;
	inline function get_wid() return currLevel.pxWid;

	public var hei(get, never) : Int;
	inline function get_hei() return currLevel.pxHei;

	public function new() {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.GAME_SCROLLER_BG);
	}

	public inline function isValid(cx, cy)
		return cx >= 0 && cx < wid && cy >= 0 && cy < hei;

	public inline function coordId(cx, cy)
		return cx + cy * wid;

	public inline function hasCollision(cx, cy) : Bool
		return false; // TODO: collision with entities and obstacles

	override function init() {
		super.init();

		if (root != null)
			initLevel();
	}

	public function initLevel() {
		// Get level background image
		if (currLevel.hasBgImage()) {
			var background = currLevel.getBgBitmap();
			root.addChild(background);
		}

		// Render an auto-layer
		// TODO add layer render root.addChild( level.l_Collisions.render() );

		// Update camera zoom
		Const.SCALE = Game.ME.w() / (Const.MAX_CELLS_PER_WIDTH * Const.GRID);
	}

	override function onResize() {
		super.onResize();

		// Update camera zoom
		Const.SCALE = Game.ME.w() / (Const.MAX_CELLS_PER_WIDTH * Const.GRID);
	}

	public function render() {}

	override function postUpdate() {
		super.postUpdate();

		render();
	}
}

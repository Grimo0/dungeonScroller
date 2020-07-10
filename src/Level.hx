class Level extends dn.Process {
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;
	public var fx(get, never) : Fx;
	inline function get_fx() return game.fx;

	public var currLevel : Data.Levels; // FIXME: Replace with your data level type

	public var wid(get, never) : Int;
	inline function get_wid() return currLevel.width;

	public var hei(get, never) : Int;
	inline function get_hei() return currLevel.height;

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

	override function init() {
		super.init();
		
		if (root != null)
			initLevel();
	}

	public function setLevel(id : Data.LevelsKind) {
		currLevel = Data.levels.get(id);
		initLevel();
	}

	public function initLevel() {
		var cdb = new h2d.CdbLevel(Data.levels, 0);
		cdb.redraw();

		// Add level layers to the root
		for (layer in cdb.layers) {
			root.addChild(layer.content);
		}

		// Update camera zoom
		Const.SCALE = Game.ME.w() / (Const.MAX_CELLS_PER_WIDTH * Const.GRID);
	}

	override function onResize() {
		super.onResize();
		
		// Update camera zoom
		Const.SCALE = Game.ME.w() / (Const.MAX_CELLS_PER_WIDTH * Const.GRID);
	}

	public function render() {
	}

	override function postUpdate() {
		super.postUpdate();

		render();
	}
}

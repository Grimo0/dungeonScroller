import en.Player;

class Level extends dn.Process {
	public var game(get, never) : Game;
	inline function get_game() return Game.ME;
	public var fx(get, never) : Fx;
	inline function get_fx() return game.fx;

	public var currLevel(default, set) : LDtkMap.LDtkMap_Level;
	public function set_currLevel(l : LDtkMap.LDtkMap_Level) {
		currLevel = l;
		initLevel();
		return currLevel;
	}

	public var gridSize(get, never) : Int;
	inline function get_gridSize() return currLevel.l_Floor.gridSize;

	public var wid(get, never) : Int;
	inline function get_wid() return currLevel.pxWid;

	public var hei(get, never) : Int;
	inline function get_hei() return currLevel.pxHei;

	public function new() {
		super(game);
		createRootInLayers(game.scroller, Const.GAME_SCROLLER_LEVEL);
	}

	public inline function isValid(cx, cy)
		return cx >= 0 && cx < wid && cy >= 0 && cy < hei;

	public inline function coordId(cx, cy)
		return cx + cy * wid;

	public inline function hasCollision(cx, cy) : Bool
		return false; // TODO: collision with entities and obstacles

	public inline function getFloor(cx, cy) : Int
		return currLevel.l_Floor.getInt(cx, cy);

	public inline function getCeiling(cx, cy) : Int
		return currLevel.l_Ceiling.getInt(cx, cy);

	override function init() {
		super.init();

		if (root != null)
			initLevel();
	}

	public function initLevel() {
		game.scroller.add(root, Const.GAME_SCROLLER_LEVEL);
		root.removeChildren();

		// Get level background image
		if (currLevel.hasBgImage()) {
			var background = currLevel.getBgBitmap();
			root.add(background, Const.GAME_LEVEL_BG);
		}

		root.add(currLevel.l_Floor.render(), Const.GAME_LEVEL_FLOOR);

		for (pEnt in currLevel.l_Entities.all_Player) {
			// Read h2d.Tile
			var tileset = Assets.world.tilesets.get(pEnt.defaultTileInfos.tilesetUid);
			if (tileset == null)
				continue;
			var tile = tileset.getFreeTile(pEnt.defaultTileInfos.x, pEnt.defaultTileInfos.y, pEnt.defaultTileInfos.w, pEnt.defaultTileInfos.h);
			if (tile == null)
				continue;

			// Create the player
			var p = new Player(pEnt.identifier);
			p.spr.tile.switchTexture(tile);
			p.spr.tile.setPosition(tile.x, tile.y);
			p.spr.tile.setSize(tile.width, tile.height);
			p.spr.tile.setCenterRatio(pEnt.pivotX, pEnt.pivotY);
			p.setPosCell(pEnt.cx, pEnt.cy);

			game.camera.trackTarget(p, true);

			break; // Only one player
		};

		root.add(currLevel.l_Ceiling.render(), Const.GAME_LEVEL_CEILING);

		// Update camera zoom
		Const.SCALE = w() / (Const.MAX_CELLS_PER_WIDTH * gridSize);
	}

	override function onResize() {
		if (currLevel == null)
			return;
		super.onResize();

		// Update camera zoom
		Const.SCALE = w() / (Const.MAX_CELLS_PER_WIDTH * gridSize);
	}

	public function render() {}

	override function postUpdate() {
		super.postUpdate();

		render();
	}
}

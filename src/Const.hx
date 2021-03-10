class Const {
	public static var FPS = 30;
	public static var FIXED_FPS = 30;
	public static var AUTO_SCALE_TARGET_WID = -1; // -1 to disable auto-scaling on width
	public static var AUTO_SCALE_TARGET_HEI = -1; // -1 to disable auto-scaling on height
	public static var SCALE = 1.0; // ignored if auto-scaling
	public static var UI_SCALE = 1.0;
	public static var AUTO_SCALE_UI_TARGET_HEI = 1080; // -1 to disable auto-scaling on height
	public static var MAX_CELLS_PER_WIDTH = 14;

	static var _uniq = 0;
	public static var NEXT_UNIQ(get, never) : Int;

	static inline function get_NEXT_UNIQ()
		return _uniq++;

	public static var INFINITE = 999999;

	static var _inc = 0;
	public static var MAIN_LAYER_GAME = _inc++;
	public static var MAIN_LAYER_UI = _inc++;

	public static var GAME_SCROLLER = _inc = 0;
	public static var GAME_DEBUG = _inc++;
	public static var GAME_CINEMATIC = _inc++;

	public static var GAME_SCROLLER_LEVEL = _inc = 0;
	public static var GAME_SCROLLER_FX_BG = _inc++;
	public static var GAME_SCROLLER_FX_FRONT = _inc++;

	public static var GAME_LEVEL_BG = _inc = 0;
	public static var GAME_LEVEL_FLOOR = _inc++;
	public static var GAME_LEVEL_ENTITIES = _inc++;
	public static var GAME_LEVEL_CEILING = _inc++;
	public static var GAME_LEVEL_TOP = _inc++;
}

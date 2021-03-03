import imgui.ImGuiDrawable;
import imgui.ImGui;

class Boot extends hxd.App {
	public static var ME : Boot;

	// Boot
	static function main() {
		new Boot();
	}

	var speed = 1.0;
	var imguiDrawable : ImGuiDrawable;

	// Engine ready
	override function init() {
		ME = this;
		new Main(s2d);

		imguiDrawable = new ImGuiDrawable(s2d);
		var style : ImGuiStyle = ImGui.getStyle();
		style.WindowBorderSize = 0;
		style.WindowRounding = 0;
		style.WindowPadding.x = 2;
		style.WindowPadding.y = 2;
		ImGui.setStyle(style);

		onResize();
	}

	override function onResize() {
		super.onResize();

		ImGui.setDisplaySize(s2d.width, s2d.height);

		dn.Process.resizeAll();
	}

	override function update(deltaTime : Float) {
		super.update(deltaTime);

		#if debug
		imguiDrawable.update(deltaTime);
		ImGui.newFrame();

		var debug = Main.ME.debug;
		if (debug) {
			ImGui.setNextWindowPos({x: 0, y: 0});
			ImGui.setNextWindowSize({x: 300, y: s2d.height});
			ImGui.begin('Debug (F1)###Debug##Default', ImGuiWindowFlags.NoResize & ImGuiWindowFlags.NoMove);
		}
		#end

		var tmod = hxd.Timer.tmod * speed;
		dn.heaps.Controller.beforeUpdate();
		dn.Process.updateAll(tmod);

		#if debug
		if (debug) {
			ImGui.end();
		}

		ImGui.render();
		#end
	}
}

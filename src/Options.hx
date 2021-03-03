import imgui.ImGui;

class Options {
	public static var ME : Options;

	public var invertY = false;
	
	public function new() {
		ME = this;
	}

	public function load() {
		var sav = hxd.Save.load(this, 'save/options');

		invertY = sav.invertY;
	}

	public function save() {
		hxd.Save.save(this, 'save/options');
	}

	public function imGuiDebugFields() {
		var natArray = new hl.NativeArray<Single>(1);
		var ref : hl.Ref<Bool>;
		
		ref = new hl.Ref(invertY);
		if (ImGui.checkbox("invertY", ref))
			invertY = ref.get();
	}
}
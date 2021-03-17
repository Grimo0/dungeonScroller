class Options {
	public static var ME : Options;

	public var speedMul = 1.;
	
	public function new() {
		ME = this;
	}

	public function load() {
		var sav = hxd.Save.load(this, 'save/options');

		speedMul = sav.speedMul;
	}

	public function save() {
		hxd.Save.save(this, 'save/options');
	}

	#if debug
	public function imGuiDebugFields() {
		var natArray = new hl.NativeArray<Single>(1);
		
		natArray[0] = speedMul;
		if (ImGui.sliderFloat('speedMul', natArray, 0, 10, '%.1f'))
			speedMul = natArray[0];
	}
	#end
}
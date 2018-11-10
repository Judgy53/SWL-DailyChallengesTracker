import flash.geom.Point;
import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.judgy.dct.DCTWindow;
import com.judgy.dct.DCTIcon;
import com.judgy.dct.DCTFormat;


class com.judgy.dct.DCTMod {
	private var m_swfRoot:MovieClip; 
	
	private var m_icon:DCTIcon;
	private var m_window:DCTWindow;
	
	private var DV_Window:DistributedValue;
	private var DV_UpdateInterval:DistributedValue
	
	private var m_windowPos:Point;
	private var m_updateInterval:Number;
	
	public static function main(swfRoot:MovieClip) {
		var s_app = new DCTMod(swfRoot);
		
		swfRoot.onLoad = function() { s_app.Load(); };
		swfRoot.onUnload = function() { s_app.Unload(); };
		swfRoot.OnModuleActivated = function(config:Archive) { s_app.LoadConfig(config);};
		swfRoot.OnModuleDeactivated = function() { return s_app.SaveConfig(); };
	}
	
	public function DCTMod(swfRoot:MovieClip) {
		m_swfRoot = swfRoot;
		
		DV_Window = DistributedValue.Create("DCT_Window");
		DV_UpdateInterval = DistributedValue.Create("DCT_UpdateInterval");
    }
	
	public function Load() {	
		DV_Window.SignalChanged.Connect(SlotWindowChanged, this);
		DV_UpdateInterval.SignalChanged.Connect(SlotUpdateIntervalChanged, this);
		
		m_icon = new DCTIcon(m_swfRoot);
		
		DCTFormat.Setup();
	}
	
	public function OnUnload() {		
		DV_Window.SignalChanged.Disconnect(SlotWindowChanged, this);
		
		m_icon.Unload();
		m_icon = undefined;
	}
	
	public function LoadConfig(config:Archive) {
		var iconPos = config.FindEntry("IconPos", new Point(400, 0));
		m_icon.SetPos(iconPos);
		m_windowPos = config.FindEntry("WindowPos", new Point(25, 100));
		DV_UpdateInterval.SetValue(config.FindEntry("UpdateInterval", 3000));
		
		//force opening on reloadui (after config is loaded)
		if (DV_Window.GetValue())
			DV_Window.SignalChanged.Emit();
	}
	
	public function SaveConfig() {	
		var archive: Archive = new Archive();
		
		archive.AddEntry("IconPos", m_icon.GetPos());
		archive.AddEntry("WindowPos", m_windowPos);
		archive.AddEntry("UpdateInterval", m_updateInterval);
		
		return archive;
	}
	
	private function SlotWindowChanged(dv:DistributedValue) {
		if (DV_Window.GetValue()) {
			if (m_window)
				m_window.Unload();
			m_window = new DCTWindow(m_swfRoot, m_windowPos);
			m_window.SetUpdateInterval(m_updateInterval);
			m_window.Draw();
		} else {
			m_windowPos = m_window.GetPos();
			m_window.Unload();
			m_window = undefined;
		}
	}
	
	private function SlotUpdateIntervalChanged(dv:DistributedValue) {
		var val:Number = Number(DV_UpdateInterval.GetValue());
		if(!isNaN(val)) {
			m_updateInterval = val;
			
			if (m_window)
				m_window.SetUpdateInterval(m_updateInterval);
		}
	}
}
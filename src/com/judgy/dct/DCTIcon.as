import com.GameInterface.DistributedValueBase;
import flash.geom.Point;
import mx.utils.Delegate;
import com.Utils.GlobalSignal;

class com.judgy.dct.DCTIcon
{
	private var m_swfRoot:MovieClip;
	private var m_icon:MovieClip;
	private var m_pos:Point;
	
	public function DCTIcon(swfRoot:MovieClip) {
		m_swfRoot = swfRoot;
	}
	
	public function SetPos(pos:Point) {
		m_pos = pos;
		if (!m_icon) CreateClip();
	}
	
	public function Unload() {
		GlobalSignal.SignalSetGUIEditMode.Disconnect(GuiEdit, this);
		
		m_icon.removeMovieClip();
		m_icon = undefined;
	}
	
	public function GetPos() {
		return m_pos;
	}
	
	private function GuiEdit(state:Boolean) {
		if (state) {
			m_icon.onPress = Delegate.create(this, function () {
				this.m_icon.startDrag();
			});
			m_icon.onRelease = Delegate.create(this, function () {
				this.m_icon.stopDrag();
			});
			m_icon.onReleaseOutside = Delegate.create(this, function () {
				this.m_icon.stopDrag();
			});
		} else {
			m_icon.stopDrag();
			m_icon.onPress = Delegate.create(this,ToggleTracker);
			m_icon.onRelease = undefined;
			m_icon.onReleaseOutside = undefined;
			
			m_pos = new Point(m_icon._x, m_icon._y);
		}
	}
	
	private function ToggleTracker() {
		DistributedValueBase.SetDValue("DCT_Window", !DistributedValueBase.GetDValue("DCT_Window"));
	}
	
	private function CreateClip() {
		m_icon = m_swfRoot.attachMovie("src.assets.icon.png", "m_icon", m_swfRoot.getNextHighestDepth(), {_x:m_pos.x, _y:m_pos.y, _width:25, _height:25});
		GlobalSignal.SignalSetGUIEditMode.Connect(GuiEdit, this);
		GuiEdit(false);
	}
}
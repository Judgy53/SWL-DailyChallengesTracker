import com.GameInterface.Quest;
import com.GameInterface.QuestGoal;
import com.judgy.dct.DCTFormat;

class com.judgy.dct.DCTChallenge
{
	private var m_window:MovieClip;
	private var m_cont:MovieClip;
	
	public var m_challenge:Quest;
	private var m_index:Number;
	private var m_locked:Boolean;
	private var m_complete:Boolean;
	
	private var m_textfieldName:TextField;
	private var m_textfieldProgress:TextField;
	
	public function DCTChallenge(challenge:Quest, index:Number, locked:Boolean, window:MovieClip) {
		m_challenge = challenge;
		m_index = index;
		m_locked = locked;
		m_window = window;
		
		m_complete = false;
	}
	
	public function Unload() {
		m_textfieldName.removeTextField();
		m_textfieldName = undefined;
		
		m_textfieldProgress.removeTextField();
		m_textfieldProgress = undefined;
		
		m_cont.removeMovieClip();
		m_cont = undefined;
	}
	
	public function Draw() {
		m_cont = m_window.createEmptyMovieClip("challenge_" + m_index, m_window.getNextHighestDepth(), 0, DCTFormat.CHALLENGE_HEIGHT * m_index);
		
		m_cont._x = 0;
		m_cont._y = DCTFormat.CHALLENGE_HEIGHT * m_index;
		
		m_textfieldName = m_cont.createTextField("challenge_" + m_index + "_name", m_cont.getNextHighestDepth(), 0, 0, DCTFormat.CHALLENGE_WIDTH, DCTFormat.CHALLENGE_HEIGHT);
		m_textfieldProgress = m_cont.createTextField("challenge_" + m_index + "_progress", m_cont.getNextHighestDepth(), DCTFormat.CHALLENGE_WIDTH, 0, DCTFormat.CHALLENGE_WIDTH, DCTFormat.CHALLENGE_HEIGHT);
		
		m_textfieldName.autoSize = "left";
		m_textfieldProgress.autoSize = "right";
		
		m_complete = m_challenge.m_CooldownExpireTime != undefined;
		
		UpdateContent();
	}
	
	public function UpdateContent(forcedProgress:Number) {
		var goal:QuestGoal = m_challenge.m_CurrentTask.m_Goals[0];
		
		if (m_locked) {
			m_textfieldName.setNewTextFormat(DCTFormat.TF_BONUS_LOCKED);
			m_textfieldProgress.setNewTextFormat(DCTFormat.TF_BONUS_LOCKED);
			
			m_textfieldProgress.text = "LOCKED";
		}
		else if (m_complete) {
			m_textfieldName.setNewTextFormat(DCTFormat.TF_NAME_COMPLETE);
			m_textfieldProgress.setNewTextFormat(DCTFormat.TF_PROGRESS_COMPLETE);
			
			m_textfieldProgress.text = "COMPLETE";
		} else {
			m_textfieldName.setNewTextFormat(DCTFormat.TF_NAME_ACTIVE);
			m_textfieldProgress.setNewTextFormat(DCTFormat.TF_PROGRESS_ACTIVE);
			
			var progress = forcedProgress != undefined ? forcedProgress : goal.m_SolvedTimes;
			
			m_textfieldProgress.text = progress + "/" + goal.m_RepeatCount;
		}
		
		m_textfieldName.text = m_challenge.m_MissionName;
		m_textfieldProgress._x = DCTFormat.CHALLENGE_WIDTH - m_textfieldProgress._width;
	}
	
	public function SetComplete(complete:Boolean) {
		m_complete = complete;
		UpdateContent();
	}
	
	public function SetLocked(locked:Boolean) {
		m_locked = locked;
		UpdateContent();
	}
	
}
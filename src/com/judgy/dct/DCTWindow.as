import com.Utils.Signal;
import com.judgy.dct.DCTChallenge;
import flash.geom.Point;
import mx.utils.Delegate;
import com.Utils.GlobalSignal;
import com.GameInterface.Quests;

class com.judgy.dct.DCTWindow
{
	private var m_swfRoot:MovieClip;
	
	private var m_pos:Point;
	
	private var m_window:MovieClip;
	
	private var m_dailyComplete:Number = 0;
	private var m_dailyTotal:Number = 0;
	private var m_challenges:Array = new Array();
	
	private var m_updateInterval:Number;
	private var m_updateIntervalMS:Number;
	
	public var SignalPosChanged:Signal = new Signal();
	
	public function DCTWindow(swfroot:MovieClip, pos:Point) {
		m_swfRoot = swfroot;
		m_pos = pos;
	}
	
	public function Unload() {
		clearInterval(m_updateInterval);
		
		Quests.SignalTaskAdded.Disconnect(PopulateChallenges, this); 
		Quests.SignalMissionRemoved.Disconnect(PopulateChallenges, this); 
		Quests.SignalMissionCompleted.Disconnect(SlotMissionCompleted, this); 
		Quests.SignalGoalProgress.Disconnect(SlotGoalProgress, this); 
		
		GlobalSignal.SignalSetGUIEditMode.Disconnect(GuiEdit, this);
		
		ClearChallenges();
		
		m_window.removeMovieClip();
		m_window = undefined;
	}
	
	public function GetPos() {
		return m_pos;
	}
	
	public function SetUpdateInterval(interval:Number) {
		m_updateIntervalMS = interval;
		
		clearInterval(m_updateInterval);
		m_updateInterval = setInterval(this, "PopulateChallenges", interval);
	}
	
	private function GuiEdit(state:Boolean) {
		if (state) {
			m_window.onPress = Delegate.create(this, function () {
				this.m_window.startDrag();
			});
			m_window.onRelease = Delegate.create(this, function () {
				this.m_window.stopDrag();
			});
			m_window.onReleaseOutside = Delegate.create(this, function () {
				this.m_window.stopDrag();
			});
		} else {
			m_window.stopDrag();
			m_window.onPress = undefined;
			m_window.onRelease = undefined;
			m_window.onReleaseOutside = undefined;
			
			m_pos = new Point(m_window._x, m_window._y);
			SignalPosChanged.Emit(m_pos);
		}
	}
	
	public function Draw() {
		m_window = m_swfRoot.createEmptyMovieClip("m_window", m_swfRoot.getNextHighestDepth());
		
		m_window._x = m_pos.x;
		m_window._y = m_pos.y;
		
		m_window.beginFill(0x000000, 33);
		m_window.moveTo(0, 0);	
		m_window.lineTo(233, 0);
		m_window.lineTo(233, 200);
		m_window.lineTo(0, 200);
		m_window.lineTo(0, 0);
		m_window.endFill();
		
		Quests.SignalTaskAdded.Connect(PopulateChallenges, this); // Useless ?
		Quests.SignalMissionRemoved.Connect(PopulateChallenges, this); // Useless ?
		Quests.SignalMissionCompleted.Connect(SlotMissionCompleted, this); // DOESN'T WORK
		Quests.SignalGoalProgress.Connect(SlotGoalProgress, this); // DOESN'T WORK
		
		SetUpdateInterval(m_updateIntervalMS);
		PopulateChallenges();
		
		GlobalSignal.SignalSetGUIEditMode.Connect(GuiEdit, this);
		GuiEdit(false);
	}
	
	private function ClearChallenges() {
		while (m_challenges.length > 0)
			m_challenges.shift().Unload();
	}
	
	private function PopulateChallenges() {	
		ClearChallenges();
		
		var allChallenges:Array = Quests.GetAllActiveChallenges().concat(Quests.GetAllCompletedChallenges());
		var dailyChallenges:Array = new Array();		
		var bonusChallenges:Array = new Array();
		
		for (var i = 0; i < allChallenges.length; i++) {
			switch(allChallenges[i].m_MissionType) {
				case _global.Enums.MainQuestType.e_DailyMission:
				case _global.Enums.MainQuestType.e_DailyDungeon:
				case _global.Enums.MainQuestType.e_DailyRandomDungeon:
				case _global.Enums.MainQuestType.e_DailyPvP:
				case _global.Enums.MainQuestType.e_DailyMassivePvP:
				case _global.Enums.MainQuestType.e_DailyScenario:
					dailyChallenges.push(allChallenges[i]);
					break;
				
				case _global.Enums.MainQuestType.e_WeeklyMission:
				case _global.Enums.MainQuestType.e_WeeklyDungeon:
				case _global.Enums.MainQuestType.e_WeeklyRaid:
				case _global.Enums.MainQuestType.e_WeeklyPvP:
				case _global.Enums.MainQuestType.e_WeeklyScenario:
					bonusChallenges.push(allChallenges[i]);
					break;
				default:
			}
		}
		
		dailyChallenges.sortOn("m_SortOrder");
		bonusChallenges.sortOn("m_SortOrder");		
				
		m_dailyComplete = 0;
		m_dailyTotal = dailyChallenges.length;
		
		for (var i = 0; i < dailyChallenges.length; i++) {
			if (dailyChallenges[i].m_CooldownExpireTime != undefined)
				m_dailyComplete++;
			
			var chal:DCTChallenge = new DCTChallenge(dailyChallenges[i], i, false, m_window);
			chal.Draw();
			
			m_challenges.push(chal);
		}
		
		var bonusLocked:Boolean = m_dailyComplete < m_dailyTotal;
		
		for (var i = 0; i < bonusChallenges.length; i++) {
			var chal:DCTChallenge = new DCTChallenge(bonusChallenges[i], dailyChallenges.length + i, bonusLocked, m_window);
			chal.Draw();
			
			m_challenges.push(chal);
		}
	}
	
	private function SlotMissionCompleted(missionId:Number) {
		for (var i = 0; i < m_challenges.length; i++) {
			if (m_challenges[i].m_challenge.m_ID) {
				m_challenges[i].SetComplete(true);
				m_dailyComplete++;
			}
		}
		
		if (m_dailyComplete >= m_dailyTotal) { 
			//all dailies are done, unlock bonus challenges
			for (var i = 0; i < m_challenges.length; i++)
				m_challenges[i].SetLocked(false);
		}
	}
	
	private function SlotGoalProgress(tierId:Number, goalId:Number, solvedTimes:Number, repeatCount:Number) {
		for (var i = 0; i < m_challenges.length; i++) {
			if (goalId == m_challenges[i].m_challenge.m_CurrentTask.m_Goals[0].m_ID)
				m_challenges[i].UpdateContent(solvedTimes);
		}
	}
}
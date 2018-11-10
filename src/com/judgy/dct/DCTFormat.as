
class com.judgy.dct.DCTFormat
{
	public static var CHALLENGE_WIDTH:Number = 230;
	public static var CHALLENGE_HEIGHT:Number = 20;
	
	public static var TF_NAME_ACTIVE:TextFormat;
	public static var TF_NAME_COMPLETE:TextFormat;
	public static var TF_PROGRESS_ACTIVE:TextFormat;
	public static var TF_PROGRESS_COMPLETE:TextFormat;
	public static var TF_BONUS_LOCKED:TextFormat;
	
	public function DCTFormat() {
	}
	
	public static function Setup() {
		TF_NAME_ACTIVE 			= new TextFormat("src.assets.fonts.FuturaMD_BT.ttf", 14, 0xFFFFFF, true, false, false);
		TF_NAME_COMPLETE 		= new TextFormat("src.assets.fonts.FuturaMD_BT.ttf", 14, 0x787878, false, false, false);
		TF_PROGRESS_ACTIVE 		= new TextFormat("src.assets.fonts.FuturaMD_BT.ttf", 14, 0xFFFFFF, true, false, false);
		TF_PROGRESS_COMPLETE 	= new TextFormat("src.assets.fonts.FuturaMD_BT.ttf", 14, 0x787878, false, false, false);
		TF_BONUS_LOCKED 		= new TextFormat("src.assets.fonts.FuturaMD_BT.ttf", 14, 0x212121, false, false, false);
	}
	
}
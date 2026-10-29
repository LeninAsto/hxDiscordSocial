package hxdiscordsocial.native;

#if (cpp && windows && hxdiscordsocial_native)
import cpp.ConstCharStar;
import cpp.Int64;

@:include("HxDiscordSocialBridge.h")
@:build(hxdiscordsocial.internal.NativeBuild.configure())
extern class SocialSdkNative {
	@:native("hds_initialize")
	public static function initialize(applicationId:ConstCharStar):Bool;

	@:native("hds_set_presence")
	public static function setPresence(name:ConstCharStar, activityType:Int, statusDisplayType:Int, details:ConstCharStar, detailsUrl:ConstCharStar,
		state:ConstCharStar, stateUrl:ConstCharStar, largeImage:ConstCharStar, largeText:ConstCharStar, largeUrl:ConstCharStar, smallImage:ConstCharStar,
		smallText:ConstCharStar, smallUrl:ConstCharStar, inviteCoverImage:ConstCharStar, startTimestamp:Int64, hasStartTimestamp:Bool, endTimestamp:Int64,
		hasEndTimestamp:Bool, buttonOneLabel:ConstCharStar, buttonOneUrl:ConstCharStar, buttonTwoLabel:ConstCharStar, buttonTwoUrl:ConstCharStar,
		partyId:ConstCharStar, partyCurrentSize:Int, partyMaxSize:Int, partyPrivacy:Int, joinSecret:ConstCharStar, supportedPlatforms:Int):Bool;

	@:native("hds_clear_presence")
	public static function clearPresence():Bool;

	@:native("hds_run_callbacks")
	public static function runCallbacks():Void;

	@:native("hds_shutdown")
	public static function shutdown():Void;

	@:native("hds_pop_event")
	public static function popEvent():Int;

	@:native("hds_event_operation")
	public static function eventOperation():Int;

	@:native("hds_event_message")
	public static function eventMessage():ConstCharStar;

	@:native("hds_event_retryable")
	public static function eventRetryable():Bool;

	@:native("hds_last_error")
	public static function lastError():ConstCharStar;

	@:native("hds_version_major")
	public static function versionMajor():Int;

	@:native("hds_version_minor")
	public static function versionMinor():Int;

	@:native("hds_version_patch")
	public static function versionPatch():Int;
}
#end

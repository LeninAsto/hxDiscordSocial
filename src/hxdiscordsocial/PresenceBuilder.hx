package hxdiscordsocial;

import haxe.Int64;
import hxdiscordsocial.Presence.PresenceOptions;

/** Fluent, reusable builder for modern Rich Presence payloads. */
class PresenceBuilder {
	var options:PresenceOptions;

	public function new(?base:Presence) {
		options = base == null ? {} : {
			name: base.name, type: base.type, statusDisplayType: base.statusDisplayType,
			details: base.details, detailsUrl: base.detailsUrl, state: base.state, stateUrl: base.stateUrl,
			largeImage: base.largeImage, largeText: base.largeText, largeUrl: base.largeUrl,
			smallImage: base.smallImage, smallText: base.smallText, smallUrl: base.smallUrl,
			inviteCoverImage: base.inviteCoverImage, startTimestamp: base.startTimestamp, endTimestamp: base.endTimestamp,
			buttons: [for (button in base.buttons) button.copy()], party: base.party == null ? null : base.party.copy(),
			joinSecret: base.joinSecret, supportedPlatforms: base.supportedPlatforms
		};
	}

	public function identity(?name:String, type:ActivityType = Playing):PresenceBuilder {
		options.name = clean(name); options.type = type; return this;
	}
	public function text(?details:String, ?state:String, display:StatusDisplayType = Details):PresenceBuilder {
		options.details = clean(details); options.state = clean(state); options.statusDisplayType = display; return this;
	}
	public function links(?detailsUrl:String, ?stateUrl:String):PresenceBuilder {
		options.detailsUrl = clean(detailsUrl); options.stateUrl = clean(stateUrl); return this;
	}
	public function largeAsset(?image:String, ?text:String, ?url:String):PresenceBuilder {
		options.largeImage = asset(image); options.largeText = clean(text); options.largeUrl = clean(url); return this;
	}
	public function smallAsset(?image:String, ?text:String, ?url:String):PresenceBuilder {
		options.smallImage = asset(image); options.smallText = clean(text); options.smallUrl = clean(url); return this;
	}
	public function elapsedFrom(start:Int64):PresenceBuilder {
		options.startTimestamp = start; options.endTimestamp = null; return this;
	}
	public function remainingUntil(end:Int64):PresenceBuilder {
		options.startTimestamp = null; options.endTimestamp = end; return this;
	}
	public function timestamps(?start:Int64, ?end:Int64):PresenceBuilder {
		options.startTimestamp = start; options.endTimestamp = end; return this;
	}
	public function buttons(values:Array<PresenceButton>):PresenceBuilder {
		options.buttons = values == null ? [] : [for (button in values) button.copy()]; return this;
	}
	public function platforms(value:ActivityPlatform):PresenceBuilder {
		options.supportedPlatforms = value; return this;
	}
	public function party(value:PresenceParty, ?joinSecret:String):PresenceBuilder {
		options.party = value == null ? null : value.copy(); options.joinSecret = clean(joinSecret); return this;
	}
	public inline function build():Presence return new Presence(options);

	static function clean(value:Null<String>):Null<String> {
		if (value == null) return null;
		var result = StringTools.trim(value);
		return result.length == 0 ? null : result;
	}
	static function asset(value:Null<String>):Null<String> {
		var result = clean(value);
		if (result == null || StringTools.startsWith(result, "http://") || StringTools.startsWith(result, "https://")) return result;
		return result.toLowerCase();
	}
}

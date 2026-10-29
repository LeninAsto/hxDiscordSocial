package hxdiscordsocial;

import haxe.Int64;

typedef PresenceOptions = {
	?name:String,
	?type:ActivityType,
	?statusDisplayType:StatusDisplayType,
	?details:String,
	?detailsUrl:String,
	?state:String,
	?stateUrl:String,
	?largeImage:String,
	?largeText:String,
	?largeUrl:String,
	?smallImage:String,
	?smallText:String,
	?smallUrl:String,
	?inviteCoverImage:String,
	?startTimestamp:Int64,
	?endTimestamp:Int64,
	?buttons:Array<PresenceButton>,
	?party:PresenceParty,
	?joinSecret:String,
	?supportedPlatforms:ActivityPlatform
}

/** Modern Discord Rich Presence payload using the Social SDK activity model. */
class Presence {
	public var name:Null<String>;
	public var type:ActivityType;
	public var statusDisplayType:Null<StatusDisplayType>;
	public var details:Null<String>;
	public var detailsUrl:Null<String>;
	public var state:Null<String>;
	public var stateUrl:Null<String>;
	public var largeImage:Null<String>;
	public var largeText:Null<String>;
	public var largeUrl:Null<String>;
	public var smallImage:Null<String>;
	public var smallText:Null<String>;
	public var smallUrl:Null<String>;
	public var inviteCoverImage:Null<String>;
	public var startTimestamp:Null<Int64>;
	public var endTimestamp:Null<Int64>;
	public var buttons:Array<PresenceButton>;
	public var party:Null<PresenceParty>;
	public var joinSecret:Null<String>;
	public var supportedPlatforms:Null<ActivityPlatform>;

	public function new(options:PresenceOptions) {
		if (options == null)
			throw "Presence options cannot be null";
		if (options.buttons != null && options.buttons.length > 2)
			throw "Discord Rich Presence supports at most two buttons";

		name = options.name;
		type = options.type == null ? Playing : options.type;
		statusDisplayType = options.statusDisplayType;
		details = options.details;
		detailsUrl = options.detailsUrl;
		state = options.state;
		stateUrl = options.stateUrl;
		largeImage = options.largeImage;
		largeText = options.largeText;
		largeUrl = options.largeUrl;
		smallImage = options.smallImage;
		smallText = options.smallText;
		smallUrl = options.smallUrl;
		inviteCoverImage = options.inviteCoverImage;
		startTimestamp = options.startTimestamp;
		endTimestamp = options.endTimestamp;
		buttons = options.buttons == null ? [] : [for (button in options.buttons) button.copy()];
		party = options.party == null ? null : options.party.copy();
		joinSecret = options.joinSecret;
		supportedPlatforms = options.supportedPlatforms;
	}

	public function copy():Presence {
		return new Presence({
			name: name,
			type: type,
			statusDisplayType: statusDisplayType,
			details: details,
			detailsUrl: detailsUrl,
			state: state,
			stateUrl: stateUrl,
			largeImage: largeImage,
			largeText: largeText,
			largeUrl: largeUrl,
			smallImage: smallImage,
			smallText: smallText,
			smallUrl: smallUrl,
			inviteCoverImage: inviteCoverImage,
			startTimestamp: startTimestamp,
			endTimestamp: endTimestamp,
			buttons: buttons,
			party: party,
			joinSecret: joinSecret,
			supportedPlatforms: supportedPlatforms
		});
	}

	public function equals(other:Presence):Bool {
		return other != null
			&& name == other.name
			&& type == other.type
			&& statusDisplayType == other.statusDisplayType
			&& details == other.details
			&& detailsUrl == other.detailsUrl
			&& state == other.state
			&& stateUrl == other.stateUrl
			&& largeImage == other.largeImage
			&& largeText == other.largeText
			&& largeUrl == other.largeUrl
			&& smallImage == other.smallImage
			&& smallText == other.smallText
			&& smallUrl == other.smallUrl
			&& inviteCoverImage == other.inviteCoverImage
			&& int64Equals(startTimestamp, other.startTimestamp)
			&& int64Equals(endTimestamp, other.endTimestamp)
			&& buttonsEqual(buttons, other.buttons)
			&& partiesEqual(party, other.party)
			&& joinSecret == other.joinSecret
			&& supportedPlatforms == other.supportedPlatforms;
	}

	static function int64Equals(left:Null<Int64>, right:Null<Int64>):Bool {
		if (left == null || right == null)
			return left == null && right == null;
		return Int64.compare(left, right) == 0;
	}

	static function buttonsEqual(left:Array<PresenceButton>, right:Array<PresenceButton>):Bool {
		if (left.length != right.length)
			return false;
		for (index in 0...left.length)
			if (!left[index].equals(right[index]))
				return false;
		return true;
	}

	static function partiesEqual(left:Null<PresenceParty>, right:Null<PresenceParty>):Bool {
		if (left == null || right == null)
			return left == null && right == null;
		return left.equals(right);
	}

	public function toString():String {
		return 'Presence(name=$name, details=$details, state=$state, buttons=${buttons.length})';
	}
}

package hxdiscordsocial;

import haxe.Int64;

typedef PresenceOptions = {
	?name:String,
	?details:String,
	?state:String,
	?largeImage:String,
	?largeText:String,
	?smallImage:String,
	?smallText:String,
	?startTimestamp:Int64,
	?endTimestamp:Int64
}

/** Portable Rich Presence payload. Unix timestamps are expressed in seconds. */
class Presence {
	public var name:Null<String>;
	public var details:Null<String>;
	public var state:Null<String>;
	public var largeImage:Null<String>;
	public var largeText:Null<String>;
	public var smallImage:Null<String>;
	public var smallText:Null<String>;
	public var startTimestamp:Null<Int64>;
	public var endTimestamp:Null<Int64>;

	public function new(options:PresenceOptions) {
		if (options == null)
			throw "Presence options cannot be null";

		name = options.name;
		details = options.details;
		state = options.state;
		largeImage = options.largeImage;
		largeText = options.largeText;
		smallImage = options.smallImage;
		smallText = options.smallText;
		startTimestamp = options.startTimestamp;
		endTimestamp = options.endTimestamp;
	}

	public function copy():Presence {
		return new Presence({
			name: name,
			details: details,
			state: state,
			largeImage: largeImage,
			largeText: largeText,
			smallImage: smallImage,
			smallText: smallText,
			startTimestamp: startTimestamp,
			endTimestamp: endTimestamp
		});
	}

	public function equals(other:Presence):Bool {
		return other != null
			&& name == other.name
			&& details == other.details
			&& state == other.state
			&& largeImage == other.largeImage
			&& largeText == other.largeText
			&& smallImage == other.smallImage
			&& smallText == other.smallText
			&& int64Equals(startTimestamp, other.startTimestamp)
			&& int64Equals(endTimestamp, other.endTimestamp);
	}

	static function int64Equals(left:Null<Int64>, right:Null<Int64>):Bool {
		if (left == null || right == null)
			return left == null && right == null;
		return Int64.compare(left, right) == 0;
	}

	public function toString():String {
		return 'Presence(name=$name, details=$details, state=$state)';
	}
}

package hxdiscordsocial;

class PresenceButton {
	public final label:String;
	public final url:String;

	public function new(label:String, url:String) {
		if (label == null || StringTools.trim(label).length == 0)
			throw "Presence button label cannot be empty";
		if (url == null || StringTools.trim(url).length == 0)
			throw "Presence button URL cannot be empty";
		this.label = label;
		this.url = url;
	}

	public inline function copy():PresenceButton {
		return new PresenceButton(label, url);
	}

	public inline function equals(other:PresenceButton):Bool {
		return other != null && label == other.label && url == other.url;
	}
}

package hxdiscordsocial;

class PresenceParty {
	public final id:String;
	public final currentSize:Int;
	public final maxSize:Int;
	public final privacy:PartyPrivacy;

	public function new(id:String, currentSize:Int, maxSize:Int = 0, privacy:PartyPrivacy = Private) {
		if (id == null || StringTools.trim(id).length < 2)
			throw "Presence party ID must contain at least two characters";
		if (currentSize < 1)
			throw "Presence party current size must be at least one";
		if (maxSize < 0 || (maxSize > 0 && currentSize > maxSize))
			throw "Presence party maximum must be zero or at least the current size";
		this.id = id;
		this.currentSize = currentSize;
		this.maxSize = maxSize;
		this.privacy = privacy;
	}

	public inline function copy():PresenceParty {
		return new PresenceParty(id, currentSize, maxSize, privacy);
	}

	public inline function equals(other:PresenceParty):Bool {
		return other != null
			&& id == other.id
			&& currentSize == other.currentSize
			&& maxSize == other.maxSize
			&& privacy == other.privacy;
	}
}

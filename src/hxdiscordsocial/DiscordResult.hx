package hxdiscordsocial;

/** Synchronous local acceptance. Native completion arrives through events. */
enum DiscordResult {
	Accepted;
	Rejected(error:DiscordError);
}

class DiscordResultTools {
	public static inline function isAccepted(result:DiscordResult):Bool {
		return switch (result) {
			case Accepted: true;
			case Rejected(_): false;
		}
	}

	public static function error(result:DiscordResult):Null<DiscordError> {
		return switch (result) {
			case Accepted: null;
			case Rejected(value): value;
		}
	}
}

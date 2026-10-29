package hxdiscordsocial.backends;

import hxdiscordsocial.DiscordBackend;
import hxdiscordsocial.DiscordError;
import hxdiscordsocial.DiscordEvent;
import hxdiscordsocial.DiscordResult;
import hxdiscordsocial.Presence;

private enum FakePending {
	Set(presence:Presence);
	Clear;
}

/** Deterministic backend for unit tests, examples and API prototyping. */
class FakeBackend implements DiscordBackend {
	public var autoComplete:Bool;
	public var initializeCalls(default, null):Int = 0;
	public var setPresenceCalls(default, null):Int = 0;
	public var clearPresenceCalls(default, null):Int = 0;
	public var lastApplicationId(default, null):Null<String>;
	public var lastPresence(default, null):Null<Presence>;

	var initialized:Bool = false;
	var events:Array<DiscordEvent> = [];
	var pending:Array<FakePending> = [];

	public function new(autoComplete:Bool = true) {
		this.autoComplete = autoComplete;
	}

	public function initialize(applicationId:String):DiscordResult {
		initializeCalls++;
		initialized = true;
		lastApplicationId = applicationId;
		events.push(Ready(applicationId));
		return Accepted;
	}

	public function setPresence(presence:Presence):DiscordResult {
		if (!initialized)
			return Rejected(new DiscordError(InvalidState, "Fake backend is not initialized"));

		setPresenceCalls++;
		lastPresence = presence.copy();
		pending.push(Set(presence.copy()));
		if (autoComplete)
			completeNextSuccess();
		return Accepted;
	}

	public function clearPresence():DiscordResult {
		if (!initialized)
			return Rejected(new DiscordError(InvalidState, "Fake backend is not initialized"));

		clearPresenceCalls++;
		pending.push(Clear);
		if (autoComplete)
			completeNextSuccess();
		return Accepted;
	}

	public function completeNextSuccess():Bool {
		if (pending.length == 0)
			return false;

		switch (pending.shift()) {
			case Set(presence):
				events.push(PresenceUpdated(presence.copy()));
			case Clear:
				events.push(PresenceCleared);
		}
		return true;
	}

	public function completeNextError(message:String, retryable:Bool = true):Bool {
		if (pending.length == 0)
			return false;

		var operation = switch (pending.shift()) {
			case Set(_): DiscordOperation.SetPresence;
			case Clear: DiscordOperation.ClearPresence;
		};
		events.push(Error(operation, new DiscordError(BackendFailure, message, retryable)));
		return true;
	}

	public function disconnect(message:String = "Simulated disconnection"):Void {
		events.push(Disconnected(new DiscordError(BackendUnavailable, message, true)));
	}

	public function reconnect():Void {
		if (initialized && lastApplicationId != null)
			events.push(Ready(lastApplicationId));
	}

	public function poll():Array<DiscordEvent> {
		var result = events;
		events = [];
		return result;
	}

	public function shutdown():Void {
		initialized = false;
		pending = [];
		events = [];
	}
}

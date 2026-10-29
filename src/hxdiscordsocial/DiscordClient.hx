package hxdiscordsocial;

import hxdiscordsocial.internal.BackendFactory;
import hxdiscordsocial.internal.PendingOperation;
import hxdiscordsocial.DiscordResult.DiscordResultTools;

/** Backend-independent Discord client with main-thread event dispatch. */
class DiscordClient {
	static inline final MAX_UNSIGNED_64_DECIMAL = "18446744073709551615";

	public var state(default, null):DiscordState = Idle;
	public var applicationId(default, null):Null<String>;
	public var desiredPresence(default, null):Null<Presence>;
	public var capabilities(get, never):DiscordCapabilities;

	final backend:DiscordBackend;
	final listeners:Array<DiscordEventListener> = [];
	var localEvents:Array<DiscordEvent> = [];
	var wantsPresence:Bool = false;
	var appliedPresence:Null<Presence>;
	var hasAppliedPresence:Bool = false;
	var pending:Null<PendingOperation>;

	public function new(?backend:DiscordBackend) {
		this.backend = backend == null ? BackendFactory.create() : backend;
	}

	inline function get_capabilities():DiscordCapabilities {
		return backend.capabilities();
	}

	public function addListener(listener:DiscordEventListener):Void {
		if (listener != null && listeners.indexOf(listener) == -1)
			listeners.push(listener);
	}

	public function removeListener(listener:DiscordEventListener):Bool {
		return listeners.remove(listener);
	}

	public function initialize(applicationId:String):DiscordResult {
		var validation = validateApplicationId(applicationId, Initialize);
		if (validation != null)
			return reject(Initialize, validation);

		if (state == Initializing || state == Ready || state == Degraded) {
			if (this.applicationId == applicationId)
				return Accepted;
			return changeApplication(applicationId);
		}

		this.applicationId = applicationId;
		state = Initializing;
		var result = backend.initialize(applicationId);
		if (!DiscordResultTools.isAccepted(result)) {
			state = isUnsupported(result) ? Unsupported : Degraded;
			queueRejected(Initialize, result);
		}
		return result;
	}

	public function setPresence(presence:Presence):DiscordResult {
		if (presence == null)
			return reject(SetPresence, new DiscordError(InvalidState, "Presence cannot be null"));
		if (!canAcceptDesiredState())
			return reject(SetPresence, stateError());

		if (wantsPresence && desiredPresence != null && desiredPresence.equals(presence))
			return Accepted;

		wantsPresence = true;
		desiredPresence = presence.copy();
		pumpDesiredState();
		return Accepted;
	}

	public function clearPresence():DiscordResult {
		if (!canAcceptDesiredState())
			return reject(ClearPresence, stateError());

		if (!wantsPresence && pending == null && !hasAppliedPresence)
			return Accepted;

		wantsPresence = false;
		desiredPresence = null;
		pumpDesiredState();
		return Accepted;
	}

	public function changeApplication(applicationId:String):DiscordResult {
		var validation = validateApplicationId(applicationId, ChangeApplication);
		if (validation != null)
			return reject(ChangeApplication, validation);
		if (this.applicationId == applicationId && (state == Initializing || state == Ready))
			return Accepted;

		backend.shutdown();
		pending = null;
		hasAppliedPresence = false;
		appliedPresence = null;
		this.applicationId = applicationId;
		state = Initializing;

		var result = backend.initialize(applicationId);
		if (!DiscordResultTools.isAccepted(result)) {
			state = isUnsupported(result) ? Unsupported : Degraded;
			queueRejected(ChangeApplication, result);
		}
		return result;
	}

	/** Polls the backend and dispatches all captured events on this Haxe thread. */
	public function poll():Void {
		var events = localEvents;
		localEvents = [];
		if (state != Closed) {
			var backendEvents = backend.poll();
			if (backendEvents != null)
				for (event in backendEvents)
					events.push(event);
		}

		for (event in events) {
			handleEvent(event);
			dispatch(event);
		}
	}

	public function shutdown():Void {
		if (state == Closed)
			return;

		backend.shutdown();
		state = Closed;
		applicationId = null;
		desiredPresence = null;
		wantsPresence = false;
		pending = null;
		appliedPresence = null;
		hasAppliedPresence = false;
		localEvents.push(Shutdown);
	}

	function handleEvent(event:DiscordEvent):Void {
		switch (event) {
			case Ready(id):
				applicationId = id;
				state = Ready;
				pending = null;
				hasAppliedPresence = false;
				appliedPresence = null;
				pumpDesiredState();

			case PresenceUpdated(presence):
				pending = null;
				hasAppliedPresence = true;
				appliedPresence = presence.copy();
				pumpDesiredState();

			case PresenceCleared:
				pending = null;
				hasAppliedPresence = false;
				appliedPresence = null;
				pumpDesiredState();

			case Disconnected(_):
				state = Degraded;
				pending = null;
				hasAppliedPresence = false;
				appliedPresence = null;

			case Error(operation, _):
				if (operation == SetPresence || operation == ClearPresence)
					pending = null;

			case Shutdown:
				state = Closed;
		}
	}

	function pumpDesiredState():Void {
		if (state != Ready || pending != null)
			return;

		if (wantsPresence) {
			if (desiredPresence == null)
				return;
			if (hasAppliedPresence && appliedPresence != null && appliedPresence.equals(desiredPresence))
				return;

			var snapshot = desiredPresence.copy();
			var result = backend.setPresence(snapshot);
			if (DiscordResultTools.isAccepted(result))
				pending = Set(snapshot);
			else
				queueRejected(SetPresence, result);
		} else if (hasAppliedPresence) {
			var result = backend.clearPresence();
			if (DiscordResultTools.isAccepted(result))
				pending = Clear;
			else
				queueRejected(ClearPresence, result);
		}
	}

	function dispatch(event:DiscordEvent):Void {
		var snapshot = listeners.copy();
		for (listener in snapshot)
			listener(event);
	}

	function canAcceptDesiredState():Bool {
		return state == Initializing || state == Ready || state == Degraded;
	}

	function stateError():DiscordError {
		return new DiscordError(InvalidState, 'Discord client cannot accept presence while in state $state');
	}

	function reject(operation:DiscordOperation, error:DiscordError):DiscordResult {
		localEvents.push(Error(operation, error));
		return Rejected(error);
	}

	function queueRejected(operation:DiscordOperation, result:DiscordResult):Void {
		switch (result) {
			case Accepted:
			case Rejected(error):
				localEvents.push(Error(operation, error));
		}
	}

	static function isUnsupported(result:DiscordResult):Bool {
		return switch (result) {
			case Accepted: false;
			case Rejected(error): error.code == UnsupportedPlatform;
		}
	}

	static function validateApplicationId(value:String, operation:DiscordOperation):Null<DiscordError> {
		if (value == null || value.length == 0)
			return new DiscordError(InvalidApplicationId, "Application ID must be a positive decimal string");

		for (index in 0...value.length) {
			var code = value.charCodeAt(index);
			if (code < "0".code || code > "9".code)
				return new DiscordError(InvalidApplicationId, "Application ID must contain decimal digits only");
		}

		var firstNonZero = 0;
		while (firstNonZero < value.length && value.charCodeAt(firstNonZero) == "0".code)
			firstNonZero++;
		if (firstNonZero == value.length)
			return new DiscordError(InvalidApplicationId, "Application ID must be greater than zero");

		var normalized = value.substr(firstNonZero);
		if (normalized.length > MAX_UNSIGNED_64_DECIMAL.length
			|| (normalized.length == MAX_UNSIGNED_64_DECIMAL.length && Reflect.compare(normalized, MAX_UNSIGNED_64_DECIMAL) > 0))
			return new DiscordError(InvalidApplicationId, "Application ID exceeds an unsigned 64-bit integer");

		return null;
	}
}

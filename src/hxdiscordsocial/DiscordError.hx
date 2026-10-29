package hxdiscordsocial;

/** Stable error codes exposed without leaking backend-specific types. */
enum abstract DiscordErrorCode(String) from String to String {
	var InvalidApplicationId = "invalid_application_id";
	var InvalidState = "invalid_state";
	var UnsupportedPlatform = "unsupported_platform";
	var BackendUnavailable = "backend_unavailable";
	var BackendFailure = "backend_failure";
}

class DiscordError {
	public final code:DiscordErrorCode;
	public final message:String;
	public final retryable:Bool;

	public function new(code:DiscordErrorCode, message:String, retryable:Bool = false) {
		this.code = code;
		this.message = message;
		this.retryable = retryable;
	}

	public function toString():String {
		return '${code}: ${message}' + (retryable ? " (retryable)" : "");
	}
}

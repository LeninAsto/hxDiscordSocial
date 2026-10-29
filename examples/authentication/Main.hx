package;

import hxdiscordsocial.Discord;

class Main {
	static function main():Void {
		Discord.addListener(event -> switch (event) {
			case AuthorizationStarted:
				trace("Waiting for Discord authorization");
			case Authenticated(token):
				trace('Authorized for ${token.scopes}; store both tokens securely');
			case AuthenticationReady(user):
				trace('Signed in as ${user.displayName} (${user.id})');
			case TokenRefreshRequired:
				trace("Refresh the stored token now");
			case Error(operation, error):
				trace('$operation failed: $error');
			default:
		});

		Discord.initialize("123456789012345678");
		Discord.poll();
		Discord.authorize();

		// A real application continues calling Discord.poll() in its update loop.
	}
}

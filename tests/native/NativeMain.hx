package;

import haxe.Int64;
import hxdiscordsocial.ActivityPlatform;
import hxdiscordsocial.DiscordClient;
import hxdiscordsocial.DiscordEvent;
import hxdiscordsocial.Presence;
import hxdiscordsocial.PresenceButton;
import hxdiscordsocial.StatusDisplayType;
import hxdiscordsocial.backends.SocialSdkBackend;

class NativeMain {
	static function main():Void {
		var args = Sys.args();
		if (args.length == 0) {
			Sys.println("Usage: NativeMain <application-id>");
			Sys.exit(64);
		}

		Sys.println('Discord Social SDK ${SocialSdkBackend.sdkVersion()}');
		var completed = false;
		var failed = false;
		var client = new DiscordClient();
		client.addListener(event -> {
			Sys.println(Std.string(event));
			switch (event) {
				case PresenceUpdated(_): completed = true;
				case Error(_, _): failed = true;
				default:
			}
		});

		var result = client.initialize(args[0]);
		client.setPresence(new Presence({
			name: "hxDiscordSocial",
			statusDisplayType: StatusDisplayType.Details,
			details: "hxDiscordSocial Haxe bridge",
			detailsUrl: "https://github.com/LeninAsto/FNF-PlusEngine",
			state: "Validating typed events",
			startTimestamp: Int64.fromFloat(Date.now().getTime() / 1000),
			buttons: [new PresenceButton("Plus Engine", "https://github.com/LeninAsto/FNF-PlusEngine")],
			supportedPlatforms: ActivityPlatform.Desktop
		}));
		var deadline = haxe.Timer.stamp() + 10;
		while (!completed && !failed && haxe.Timer.stamp() < deadline) {
			client.poll();
			Sys.sleep(0.01);
		}

		if (!completed || failed) {
			Sys.println('Native bridge failed or timed out: $result');
			client.shutdown();
			Sys.exit(2);
		}

		client.clearPresence();
		client.poll();
		client.shutdown();
		client.poll();
		Sys.println("PASS: native Haxe bridge");
	}
}

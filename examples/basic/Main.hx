package;

import hxdiscordsocial.DiscordClient;
import hxdiscordsocial.Presence;
import hxdiscordsocial.backends.FakeBackend;

class Main {
	static function main():Void {
		// FakeBackend keeps this example runnable before the native 0.2.0 backend.
		var discord = new DiscordClient(new FakeBackend());
		discord.addListener(event -> trace(event));
		discord.initialize("123456789012345678");
		discord.poll();
		discord.setPresence(new Presence({
			details: "Playing: Blammed",
			state: "Freeplay - Hard",
			largeImage: "plusengine",
			largeText: "FNF Plus Engine"
		}));
		discord.poll();
		discord.shutdown();
		discord.poll();
	}
}

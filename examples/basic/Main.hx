package;

import hxdiscordsocial.DiscordClient;
import hxdiscordsocial.PresenceBuilder;
import hxdiscordsocial.backends.FakeBackend;

class Main {
	static function main():Void {
		// FakeBackend makes the example runnable without Discord or the native SDK.
		var discord = new DiscordClient(new FakeBackend());
		discord.addListener(event -> trace(event));
		discord.initialize("123456789012345678");
		discord.poll();
		discord.setPresence(new PresenceBuilder()
			.text("Exploring the northern ruins", "Chapter 3")
			.largeAsset("northern_ruins", "The Northern Ruins")
			.smallAsset("ranger", "Ranger")
			.build());
		discord.poll();
		discord.shutdown();
		discord.poll();
	}
}

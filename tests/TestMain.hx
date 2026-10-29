package;

import haxe.Int64;
import hxdiscordsocial.Discord;
import hxdiscordsocial.DiscordClient;
import hxdiscordsocial.DiscordError.DiscordErrorCode;
import hxdiscordsocial.DiscordEvent;
import hxdiscordsocial.DiscordResult;
import hxdiscordsocial.DiscordState;
import hxdiscordsocial.Presence;
import hxdiscordsocial.backends.FakeBackend;
import hxdiscordsocial.backends.UnsupportedBackend;

class TestMain {
	static var assertions:Int = 0;

	static function main():Void {
		testApplicationIdValidation();
		testUnsupportedBackend();
		testLifecycleAndInt64();
		testDeduplicationAndCoalescing();
		testClearAndReconnect();
		testChangeApplicationRetainsPresence();
		testShutdownAndReinitialize();
		testStaticFacade();
		Sys.println('PASS: $assertions assertions');
	}

	static function testApplicationIdValidation():Void {
		for (invalid in [null, "", "0", "000", "12x", " 12", "18446744073709551616"]) {
			var client = new DiscordClient(new FakeBackend());
			var events:Array<DiscordEvent> = [];
			client.addListener(events.push);
			assertRejected(client.initialize(invalid), InvalidApplicationId);
			assertEquals(0, events.length, "events must wait for poll");
			client.poll();
			assertEquals(1, events.length, "invalid ID error event");
		}

		var client = new DiscordClient(new FakeBackend());
		assertAccepted(client.initialize("18446744073709551615"));
	}

	static function testUnsupportedBackend():Void {
		var client = new DiscordClient(new UnsupportedBackend("TestOS"));
		var events:Array<DiscordEvent> = [];
		client.addListener(events.push);
		assertRejected(client.initialize("123"), UnsupportedPlatform);
		assertEquals(Unsupported, client.state, "unsupported state");
		client.poll();
		assertEquals(1, events.length, "unsupported error dispatched once");
	}

	static function testLifecycleAndInt64():Void {
		var backend = new FakeBackend();
		var client = new DiscordClient(backend);
		var events:Array<DiscordEvent> = [];
		client.addListener(events.push);

		assertAccepted(client.initialize("123456789012345678"));
		assertEquals(Initializing, client.state, "initializing before poll");
		assertEquals(0, events.length, "ready waits for poll");
		client.poll();
		assertEquals(Ready, client.state, "ready after poll");

		var timestamp = Int64.parseString("2147483648");
		var presence = new Presence({details: "Unicode: ñ 日本語", startTimestamp: timestamp});
		assertAccepted(client.setPresence(presence));
		client.poll();
		assertTrue(backend.lastPresence.equals(presence), "Int64 and Unicode survive copy");
		assertTrue(countPresenceUpdated(events) == 1, "one update event");
	}

	static function testDeduplicationAndCoalescing():Void {
		var backend = new FakeBackend(false);
		var client = new DiscordClient(backend);
		client.initialize("123");
		client.poll();

		var first = new Presence({details: "first"});
		var skipped = new Presence({details: "skipped"});
		var latest = new Presence({details: "latest"});
		client.setPresence(first);
		assertEquals(1, backend.setPresenceCalls, "first request submitted");
		client.setPresence(skipped);
		client.setPresence(latest);
		client.setPresence(latest.copy());
		assertEquals(1, backend.setPresenceCalls, "updates coalesced while in flight");

		assertTrue(backend.completeNextSuccess(), "complete first request");
		client.poll();
		assertEquals(2, backend.setPresenceCalls, "latest request submitted next");
		assertEquals("latest", backend.lastPresence.details, "intermediate state skipped");

		assertTrue(backend.completeNextSuccess(), "complete latest request");
		client.poll();
		client.setPresence(latest.copy());
		assertEquals(2, backend.setPresenceCalls, "applied duplicate ignored");
	}

	static function testClearAndReconnect():Void {
		var backend = new FakeBackend();
		var client = new DiscordClient(backend);
		client.initialize("123");
		client.poll();
		client.setPresence(new Presence({details: "kept"}));
		client.poll();
		client.clearPresence();
		client.poll();
		assertEquals(1, backend.clearPresenceCalls, "clear submitted");

		client.setPresence(new Presence({details: "restored"}));
		client.poll();
		var callsBeforeReconnect = backend.setPresenceCalls;
		backend.disconnect();
		client.poll();
		assertEquals(Degraded, client.state, "disconnect degrades client");
		backend.reconnect();
		client.poll();
		assertEquals(callsBeforeReconnect + 1, backend.setPresenceCalls, "desired state restored");
	}

	static function testChangeApplicationRetainsPresence():Void {
		var backend = new FakeBackend();
		var client = new DiscordClient(backend);
		client.initialize("111");
		client.poll();
		client.setPresence(new Presence({state: "persistent"}));
		client.poll();
		var previousCalls = backend.setPresenceCalls;

		assertAccepted(client.changeApplication("222"));
		client.poll();
		assertEquals("222", client.applicationId, "application changed");
		assertEquals(2, backend.initializeCalls, "backend initialized twice");
		assertEquals(previousCalls + 1, backend.setPresenceCalls, "presence restored for new app");
	}

	static function testShutdownAndReinitialize():Void {
		var backend = new FakeBackend();
		var client = new DiscordClient(backend);
		var shutdownEvents = 0;
		client.addListener(event -> switch (event) {
			case Shutdown: shutdownEvents++;
			default:
		});

		client.initialize("123");
		client.poll();
		client.shutdown();
		assertEquals(Closed, client.state, "closed immediately");
		assertEquals(0, shutdownEvents, "shutdown event waits for poll");
		client.poll();
		assertEquals(1, shutdownEvents, "shutdown event dispatched");
		assertAccepted(client.initialize("456"));
		client.poll();
		assertEquals(Ready, client.state, "client can restart");
	}

	static function testStaticFacade():Void {
		var backend = new FakeBackend();
		Discord.useClient(new DiscordClient(backend));
		assertAccepted(Discord.initialize("999"));
		Discord.poll();
		assertEquals(Ready, Discord.state, "facade state");
		Discord.setPresence(new Presence({details: "facade"}));
		Discord.poll();
		assertEquals("facade", backend.lastPresence.details, "facade routes presence");
		Discord.shutdown();
		Discord.poll();
	}

	static function countPresenceUpdated(events:Array<DiscordEvent>):Int {
		var count = 0;
		for (event in events)
			switch (event) {
				case PresenceUpdated(_):
					count++;
				default:
			}
		return count;
	}

	static function assertAccepted(result:DiscordResult):Void {
		assertions++;
		switch (result) {
			case Accepted:
			case Rejected(error):
				throw 'Expected Accepted, got $error';
		}
	}

	static function assertRejected(result:DiscordResult, code:DiscordErrorCode):Void {
		assertions++;
		switch (result) {
			case Accepted:
				throw 'Expected rejection $code';
			case Rejected(error):
				if (error.code != code)
					throw 'Expected rejection $code, got ${error.code}';
		}
	}

	static function assertTrue(value:Bool, message:String):Void {
		assertions++;
		if (!value)
			throw message;
	}

	static function assertEquals(expected:Dynamic, actual:Dynamic, message:String):Void {
		assertions++;
		if (expected != actual)
			throw '$message: expected $expected, got $actual';
	}
}

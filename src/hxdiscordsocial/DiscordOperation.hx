package hxdiscordsocial;

/** Operation associated with a result or asynchronous error. */
enum DiscordOperation {
	Initialize;
	SetPresence;
	ClearPresence;
	ChangeApplication;
	Poll;
	Shutdown;
}

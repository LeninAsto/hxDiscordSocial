package hxdiscordsocial;

/** Operation associated with a result or asynchronous error. */
enum DiscordOperation {
	Initialize;
	SetPresence;
	ClearPresence;
	ChangeApplication;
	Authorize;
	RestoreToken;
	RefreshToken;
	Logout;
	Poll;
	Shutdown;
}

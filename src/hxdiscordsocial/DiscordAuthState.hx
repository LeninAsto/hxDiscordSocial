package hxdiscordsocial;

enum DiscordAuthState {
	SignedOut;
	Authorizing;
	Authenticated;
	Connecting;
	Ready;
	RefreshRequired;
}

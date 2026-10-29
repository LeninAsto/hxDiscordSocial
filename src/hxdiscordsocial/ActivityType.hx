package hxdiscordsocial;

/** Discord activity type. Games should normally keep the default Playing. */
enum abstract ActivityType(Int) from Int to Int {
	var Playing = 0;
	var Streaming = 1;
	var Listening = 2;
	var Watching = 3;
	var CustomStatus = 4;
	var Competing = 5;
	var HangStatus = 6;
}

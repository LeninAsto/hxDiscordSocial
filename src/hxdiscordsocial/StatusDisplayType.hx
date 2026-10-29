package hxdiscordsocial;

/** Selects which activity field Discord uses for the compact status line. */
enum abstract StatusDisplayType(Int) from Int to Int {
	var Name = 0;
	var State = 1;
	var Details = 2;
}

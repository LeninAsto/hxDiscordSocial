package hxdiscordsocial;

/** Bit flags controlling where an activity invite can be accepted. */
enum abstract ActivityPlatform(Int) from Int to Int {
	var Desktop = 1;
	var Xbox = 2;
	var Samsung = 4;
	var IOS = 8;
	var Android = 16;
	var Embedded = 32;
	var PS4 = 64;
	var PS5 = 128;

	@:op(A | B)
	public static inline function combine(left:ActivityPlatform, right:ActivityPlatform):ActivityPlatform {
		return cast((left : Int) | (right : Int));
	}

	public inline function contains(platform:ActivityPlatform):Bool {
		return (this & (platform : Int)) != 0;
	}
}

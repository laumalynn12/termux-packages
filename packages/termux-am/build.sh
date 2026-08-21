# Contributor: @michalbednarski
TERMUX_PKG_HOMEPAGE=https://github.com/termux/TermuxAm
TERMUX_PKG_DESCRIPTION="Android Oreo-compatible am command reimplementation"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="Michal Bednarski @michalbednarski"
TERMUX_PKG_VERSION=0.8.0
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://github.com/termux/TermuxAm/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=7d4cfa2bfff93d5fc89fc89e537d2c072e08918276b140b7ed48ea45ebfbe8f3
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_CONFLICTS="termux-tools (<< 0.51)"

# Building the APK via Gradle requires installing Android SDK components,
# which fails in the builder container. Instead the pre-built APK (built for
# this app's package name/prefix) is vendored under prebuilt/ and repackaged.
_PREBUILT_DEB="$TERMUX_PKG_BUILDER_DIR/prebuilt/termux-am_0.6.0_all.deb"

termux_step_post_get_source() {
	sed -i'' -E -e "s|\@TERMUX_PREFIX\@|${TERMUX_PREFIX}|g" "$TERMUX_PKG_SRCDIR/am-libexec-packaged"
	sed -i'' -E -e "s|\@TERMUX_APP_PACKAGE\@|${TERMUX_APP_PACKAGE}|g" "$TERMUX_PKG_SRCDIR/app/src/main/java/com/termux/termuxam/FakeContext.java"
}

termux_step_make_install() {
	mkdir -p "$TERMUX_PKG_TMPDIR/termux-am-prebuilt"
	(cd "$TERMUX_PKG_TMPDIR/termux-am-prebuilt"
		ar x "$_PREBUILT_DEB"
		tar xf data.tar.xz
	)

	cp "$TERMUX_PKG_TMPDIR/termux-am-prebuilt/data/data/$TERMUX_APP_PACKAGE/files/usr/bin/am" \
		"$TERMUX_PREFIX/bin/am"
	chmod 700 "$TERMUX_PREFIX/bin/am"

	mkdir -p "$TERMUX_PREFIX/libexec/termux-am"
	cp "$TERMUX_PKG_TMPDIR/termux-am-prebuilt/data/data/$TERMUX_APP_PACKAGE/files/usr/libexec/termux-am/am.apk" \
		"$TERMUX_PREFIX/libexec/termux-am/am.apk"
}

package org.sral;

import android.app.Activity;

public class SralBootstrap {
	static {
		System.loadLibrary("SRAL");           // prebuilt, packaged from jniLibs
		System.loadLibrary("SralBootstrap");  // JNI shim; depends on libSRAL.so
	}

	public static native void init(Activity activity);
}

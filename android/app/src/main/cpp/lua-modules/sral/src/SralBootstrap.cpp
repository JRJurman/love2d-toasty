#include <jni.h>
#include "../Include/SRAL.h"

extern "C" JNIEXPORT void JNICALL
Java_org_sral_SralBootstrap_init(JNIEnv* env, jclass, jobject activity) {
	SRAL_SetEngineParameter(SRAL_ENGINE_ANDROID_TEXT_TO_SPEECH,
	                        SRAL_PARAM_ANDROID_JNI_ENV, (void*)env);
	SRAL_SetEngineParameter(SRAL_ENGINE_ANDROID_TEXT_TO_SPEECH,
	                        SRAL_PARAM_ANDROID_ACTIVITY, (void*)activity);
}

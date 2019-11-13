package com.ginireactnative;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import net.gini.android.vision.GiniVision;
import net.gini.android.vision.camera.CameraActivity;
import net.gini.android.vision.network.GiniVisionDefaultNetworkService;
import net.gini.android.vision.network.GiniVisionNetworkService;

import androidx.annotation.NonNull;

/**
 * Created by Alpar Szotyori on 12.11.2019.
 *
 * Copyright (c) 2019 Gini GmbH.
 */
public class GiniBridge extends ReactContextBaseJavaModule {

    private static final int GINI_REQUEST_CODE = 1;

    private Promise mPromise;

    public GiniBridge(@NonNull final ReactApplicationContext reactContext) {
        super(reactContext);

        reactContext.addActivityEventListener(new BaseActivityEventListener() {
            @Override
            public void onActivityResult(final Activity activity, final int requestCode,
                    final int resultCode,
                    final Intent data) {
                super.onActivityResult(activity, requestCode, resultCode, data);

                if (mPromise != null) {
                    final Activity currentActivity = getCurrentActivity();
                    if (currentActivity != null) {
                        // In a real world scenario cleanup should be called after feedback
                        // has been sent
                        GiniVision.cleanup(currentActivity);

                        mPromise.resolve("resultCode " + resultCode);
                    } else {
                        mPromise.reject("activity error", "Activity doesn't exist");
                    }
                }
            }
        });
    }

    @NonNull
    @Override
    public String getName() {
        return "GiniBridge";
    }

    @ReactMethod
    public void showGini(final Promise promise) {
        mPromise = promise;

        final Activity currentActivity = getCurrentActivity();
        if (currentActivity == null) {
            promise.reject("activity error", "Activity doesn't exist");
            return;
        }

        GiniVisionNetworkService giniNetworkService = GiniVisionDefaultNetworkService
                .builder(currentActivity)
                .setClientCredentials(
                        currentActivity.getString(R.string.gini_client_id),
                        currentActivity.getString(R.string.gini_client_secret),
                        "reactNativeExample"
                ).build();

        GiniVision.newInstance()
                .setGiniVisionNetworkService(giniNetworkService)
                .build();

        final Intent intent = new Intent(currentActivity, CameraActivity.class);
        currentActivity.startActivityForResult(intent, GINI_REQUEST_CODE);
    }
}

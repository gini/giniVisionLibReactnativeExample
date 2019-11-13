package com.ginireactnative;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.Collections;
import java.util.List;

import androidx.annotation.NonNull;

/**
 * Created by Alpar Szotyori on 12.11.2019.
 *
 * Copyright (c) 2019 Gini GmbH.
 */
public class GiniPackage implements ReactPackage {

    @NonNull
    @Override
    public List<NativeModule> createNativeModules(
            @NonNull final ReactApplicationContext reactContext) {
        return Collections.singletonList(new GiniBridge(reactContext));
    }

    @NonNull
    @Override
    public List<ViewManager> createViewManagers(
            @NonNull final ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }
}

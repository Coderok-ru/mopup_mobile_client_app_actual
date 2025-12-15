package com.coderok.mopup

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setLocale("ru_RU")
        MapKitFactory.setApiKey("55da3a31-a0c0-4799-86e7-1644e4d7a47a")
    }
}


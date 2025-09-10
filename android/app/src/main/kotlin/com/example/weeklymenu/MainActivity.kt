package com.example.weeklymenu
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
{
    override fun onCreate(savedInstanceState: Bundle?) {
        // Desactivar la animación de fade del splash screen en Android 12+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView -> 
                splashScreenView.remove()
            }
        }
        
        super.onCreate(savedInstanceState)
    }
}
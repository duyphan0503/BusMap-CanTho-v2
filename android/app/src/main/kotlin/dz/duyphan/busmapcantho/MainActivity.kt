package dz.duyphan.busmapcantho

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "dz.duyphan.busmapcantho/config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getGoogleMapsKey") {
                result.success(BuildConfig.GOOGLE_MAPS_KEY)
            } else {
                result.notImplemented()
            }
        }
    }
}

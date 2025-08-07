package com.example.flutter_keyboard_ime

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    
    private val CHANNEL = "com.example.flutter_keyboard_ime/settings"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openKeyboardSettings" -> {
                    try {
                        // Open system keyboard settings
                        val intent = android.content.Intent(android.provider.Settings.ACTION_INPUT_METHOD_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Cannot open keyboard settings", e.message)
                    }
                }
                "checkKeyboardEnabled" -> {
                    val isEnabled = isKeyboardEnabled()
                    result.success(isEnabled)
                }
                "isDefaultKeyboard" -> {
                    val isDefault = isDefaultKeyboard()
                    result.success(isDefault)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun isKeyboardEnabled(): Boolean {
        val packageName = packageName
        val inputMethodManager = getSystemService(android.content.Context.INPUT_METHOD_SERVICE) as android.view.inputmethod.InputMethodManager
        val enabledMethods = inputMethodManager.enabledInputMethodList
        
        return enabledMethods.any { 
            it.packageName == packageName 
        }
    }
    
    private fun isDefaultKeyboard(): Boolean {
        val defaultInputMethod = android.provider.Settings.Secure.getString(
            contentResolver,
            android.provider.Settings.Secure.DEFAULT_INPUT_METHOD
        )
        return defaultInputMethod?.contains(packageName) == true
    }
}
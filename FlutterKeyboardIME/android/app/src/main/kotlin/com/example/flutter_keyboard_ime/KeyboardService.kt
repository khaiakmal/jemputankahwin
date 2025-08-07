package com.example.flutter_keyboard_ime

import android.inputmethodservice.InputMethodService
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class KeyboardService : InputMethodService() {
    
    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var methodChannel: MethodChannel? = null
    
    companion object {
        private const val CHANNEL = "com.example.flutter_keyboard_ime/keyboard"
        private const val ENGINE_ID = "keyboard_engine"
    }

    override fun onCreate() {
        super.onCreate()
        initializeFlutterEngine()
    }

    private fun initializeFlutterEngine() {
        // Create or retrieve cached Flutter engine
        flutterEngine = FlutterEngineCache.getInstance().get(ENGINE_ID)
        if (flutterEngine == null) {
            flutterEngine = FlutterEngine(this)
            
            // Start executing Dart code
            flutterEngine?.dartExecutor?.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            
            // Cache the engine for reuse
            FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine!!)
        }

        // Setup method channel for communication
        setupMethodChannel()
    }

    private fun setupMethodChannel() {
        methodChannel = MethodChannel(
            flutterEngine?.dartExecutor?.binaryMessenger!!,
            CHANNEL
        )
        
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "commitText" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        currentInputConnection?.commitText(text, 1)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Text cannot be null", null)
                    }
                }
                "deleteSurroundingText" -> {
                    val beforeLength = call.argument<Int>("beforeLength") ?: 1
                    val afterLength = call.argument<Int>("afterLength") ?: 0
                    currentInputConnection?.deleteSurroundingText(beforeLength, afterLength)
                    result.success(true)
                }
                "finishComposingText" -> {
                    currentInputConnection?.finishComposingText()
                    result.success(true)
                }
                "setComposingText" -> {
                    val text = call.argument<String>("text")
                    val newCursorPosition = call.argument<Int>("newCursorPosition") ?: 1
                    if (text != null) {
                        currentInputConnection?.setComposingText(text, newCursorPosition)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Text cannot be null", null)
                    }
                }
                "sendKeyEvent" -> {
                    val keyCode = call.argument<Int>("keyCode")
                    if (keyCode != null) {
                        // Handle special key events if needed
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "KeyCode cannot be null", null)
                    }
                }
                "getSelectedText" -> {
                    val flags = call.argument<Int>("flags") ?: 0
                    val selectedText = currentInputConnection?.getSelectedText(flags)?.toString()
                    result.success(selectedText ?: "")
                }
                "getTextBeforeCursor" -> {
                    val length = call.argument<Int>("length") ?: 100
                    val flags = call.argument<Int>("flags") ?: 0
                    val textBefore = currentInputConnection?.getTextBeforeCursor(length, flags)?.toString()
                    result.success(textBefore ?: "")
                }
                "getTextAfterCursor" -> {
                    val length = call.argument<Int>("length") ?: 100
                    val flags = call.argument<Int>("flags") ?: 0
                    val textAfter = currentInputConnection?.getTextAfterCursor(length, flags)?.toString()
                    result.success(textAfter ?: "")
                }
                "hideKeyboard" -> {
                    requestHideSelf(0)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreateInputView(): View? {
        if (flutterView == null) {
            flutterView = FlutterView(this)
            flutterView?.attachToFlutterEngine(flutterEngine!!)
        }
        return flutterView
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        
        // Send input type information to Flutter
        val inputTypeInfo = mapOf(
            "inputType" to (info?.inputType ?: 0),
            "imeOptions" to (info?.imeOptions ?: 0),
            "packageName" to (info?.packageName ?: ""),
            "label" to (info?.label?.toString() ?: ""),
            "hint" to (info?.hintText?.toString() ?: "")
        )
        
        methodChannel?.invokeMethod("onStartInputView", inputTypeInfo)
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        methodChannel?.invokeMethod("onFinishInputView", finishingInput)
    }

    override fun onUpdateSelection(
        oldSelStart: Int, oldSelEnd: Int,
        newSelStart: Int, newSelEnd: Int,
        candidatesStart: Int, candidatesEnd: Int
    ) {
        super.onUpdateSelection(oldSelStart, oldSelEnd, newSelStart, newSelEnd, candidatesStart, candidatesEnd)
        
        val selectionInfo = mapOf(
            "oldSelStart" to oldSelStart,
            "oldSelEnd" to oldSelEnd,
            "newSelStart" to newSelStart,
            "newSelEnd" to newSelEnd,
            "candidatesStart" to candidatesStart,
            "candidatesEnd" to candidatesEnd
        )
        
        methodChannel?.invokeMethod("onUpdateSelection", selectionInfo)
    }

    override fun onDestroy() {
        flutterView?.detachFromFlutterEngine()
        flutterView = null
        super.onDestroy()
    }
}
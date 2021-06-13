/**
    Application

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

module common.application;

import bindbc.sdl;

import core.thread;
import std.datetime;

import core, render, ui;

import common.event;
import common.settings;
import common.resource;

private {
    float _deltatime = 1f;
    float _currentFps;
    long _tickStartFrame;

    bool _isChildGrabbed;
    uint _idChildGrabbed;
    //GuiElement[] _children;

    bool _isInitialized;
    uint _nominalFPS = 60u;
}

/// Actual framerate divided by the nominal framerate
/// 1 if the same, less if the application slow down,
/// more if the application runs too quickly.
float getDeltatime() {
    return _deltatime;
}

/// Actual framerate of the application.
float getCurrentFPS() {
    return _currentFps;
}

/// Maximum framerate of the application. \
/// The deltatime is equal to 1 if the framerate is exactly that.
uint getNominalFPS() {
    return _nominalFPS;
}
/// Ditto
uint setNominalFPS(uint fps) {
    return _nominalFPS = fps;
}

/// Application startup
void createApplication(Vec2u size, string title = "Stg") {
    if (_isInitialized)
        throw new Exception("The application cannot be run twice.");
    _isInitialized = true;
    createWindow(size, title);
    initializeEvents();
    _tickStartFrame = Clock.currStdTime();
}

/// Main application loop
void runApplication() {
    if (!_isInitialized)
        throw new Exception("Cannot run the application.");

    while (processEvents()) {
        updateEvents(_deltatime);
        updateRoots(_deltatime);
        drawRoots();

        renderWindow();

        long deltaTicks = Clock.currStdTime() - _tickStartFrame;
        if (deltaTicks < (10_000_000 / _nominalFPS))
            Thread.sleep(dur!("hnsecs")((10_000_000 / _nominalFPS) - deltaTicks));

        deltaTicks = Clock.currStdTime() - _tickStartFrame;
        _deltatime = (cast(float)(deltaTicks) / 10_000_000f) * _nominalFPS;
        _currentFps = (_deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
        _tickStartFrame = Clock.currStdTime();
    }
}

/// Cleanup and kill the application
void destroyApplication() {
    destroyEvents();
    destroyWindow();
}

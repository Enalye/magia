/**
    Checkbox

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

module ui.checkbox;

import std.conv : to;
import core, common, render;
import ui.gui_element;

/// A simple check box.
class Checkbox : GuiElement {
    private {
        bool _value;
    }

    @property {
        /// Value of the checkbox, true if checked.
        bool value() const {
            return _value;
        }
        /// Ditto
        bool value(bool v) {
            return _value = v;
        }
    }

    this() {
        size(Vec2f(25f, 25f));
    }

    override void onSubmit() {
        if (isLocked)
            return;
        _value = !_value;
        triggerCallback();
    }

    override void draw() {
        if (_value)
            drawFilledRect(origin, size, Color.white);
        /*else
            drawRect(origin, size, Color.white);*/
    }
}

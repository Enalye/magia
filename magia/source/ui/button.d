/**
    Button

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

module ui.button;

import std.conv : to;
import core, render, common;
import ui.gui_element, ui.label;

/// Simple gui that trigger its callback when onSubmit() is fired (like when you click on it).
class Button : GuiElement {
    /// Function callback triggered when *onSubmit* is called.
    void function() onClick;

    override void onSubmit() {
        if (isLocked)
            return;
        if (onClick !is null)
            onClick();
        triggerCallback();
    }
}

/// Button with a label.
class TextButton : Button {
    /// The text of the button.
    Label label;

    @property {
        alias color = label.color;
        alias text = label.text;
    }

    /// Ctor
    this(string text, Font font = getDefaultFont()) {
        label = new Label(text, font);
        label.setAlign(GuiAlignX.center, GuiAlignY.center);
        size = label.size;
        appendChild(label);
    }

    override void draw() {
        if (isLocked)
            drawFilledRect(origin, size, Color.white * 0.055f);
        else if (isSelected)
            drawFilledRect(origin, size, Color.white * 0.4f);
        else if (isHovered)
            drawFilledRect(origin, size, Color.white * 0.25f);
        else
            drawFilledRect(origin, size, Color.white * 0.15f);
    }
}

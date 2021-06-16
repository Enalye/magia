module magia.render.font.font;

import magia.core;
import magia.render.texture;
import magia.render.font.glyph;

private {
    Font _defaultFont;
}

void setDefaultFont(Font font) {
    _defaultFont = font;
}

Font getDefaultFont() {
    assert(_defaultFont, "Default font not set");
    return _defaultFont;
}

/// Font that renders text to texture.
interface Font {
    @property {
        /// Font name
        string name() const;
        /// Default font size
        int size() const;
        /// Where the top is above the baseline
        int ascent() const;
        /// Where the bottom is below the baseline
        int descent() const;
        /// Distance between each baselines
        int lineSkip() const;
    }

    int getKerning(dchar prevChar, dchar currChar);

    Glyph getMetrics(dchar character);
}

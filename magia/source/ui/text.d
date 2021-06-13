/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module ui.text;

import std.regex;
import std.algorithm.comparison : min;
import std.utf, std.random;
import std.conv : to;
import std.string;
import core, render, common;
import ui.gui_element;

/// Dynamic text rendering
final class Text : GuiElement {
    private {
        Font _font;
        Timer _timer, _effectTimer;
        dstring _text;
        size_t _currentIndex;
        Token[] _tokens;
        float _delay = 0f;
        int _charSpacing = 0;
    }

    @property {
        /// Text
        string text() const {
            return to!string(_text);
        }
        /// Ditto
        string text(string text_) {
            _text = to!dstring(text_);
            restart();
            tokenize();
            return text_;
        }

        /// Font
        Font font() const {
            return cast(Font) _font;
        }
        /// Ditto
        Font font(Font font_) {
            _font = font_;
            restart();
            tokenize();
            return _font;
        }

        /// Is the text still being displayed ?
        bool isPlaying() const {
            return _timer.isRunning() || (_currentIndex < _tokens.length);
        }

        /// Default delay between each character
        float delay() const {
            return _delay;
        }
        /// Ditto
        float delay(float delay_) {
            return _delay = delay_;
        }

        /// Characters per second
        int cps() const {
            return (_delay <= 0f) ? 0 : cast(int)(1f / _delay);
        }
        /// Ditto
        int cps(int cps_) {
            _delay = (cps_ == 0) ? 0f : (1f / cps_);
            return cps_;
        }

        /// Default additionnal spacing between each character
        int charSpacing() const {
            return _charSpacing;
        }
        /// Ditto
        int charSpacing(int charSpacing_) {
            return _charSpacing = charSpacing_;
        }
    }

    /// Build text with default font
    this(string text_ = "", Font font_ = getDefaultFont()) {
        setInitFlags(Init.notInteractable);
        _font = font_;
        _text = to!dstring(text_);
        tokenize();
        _effectTimer.mode = Timer.Mode.loop;
        _effectTimer.start(1f);
    }

    /// Restart the reading from the beginning
    void restart() {
        _currentIndex = 0;
        _timer.reset();
    }

    private struct Token {
        enum Type {
            character,
            line,
            scale,
            charSpacing,
            color,
            delay,
            pause,
            effect
        }

        Type type;

        union {
            CharToken character;
            ScaleToken scale;
            SpacingToken charSpacing;
            ColorToken color;
            DelayToken delay;
            PauseToken pause;
            EffectToken effect;
        }

        struct CharToken {
            dchar character;
        }

        struct ScaleToken {
            int scale;
        }

        struct SpacingToken {
            int charSpacing;
        }

        struct ColorToken {
            Color color;
        }

        struct DelayToken {
            float duration;
        }

        struct PauseToken {
            float duration;
        }

        struct EffectToken {
            enum Type {
                none,
                wave,
                bounce,
                shake,
                rainbow
            }

            Type type;
        }
    }

    private void tokenize() {
        size_t current = 0;
        _tokens.length = 0;
        while (current < _text.length) {
            if (_text[current] == '\n') {
                current++;
                Token token;
                token.type = Token.Type.line;
                _tokens ~= token;
            }
            else if (_text[current] == '{') {
                current++;
                size_t endOfBrackets = indexOf(_text, "}", current);
                if (endOfBrackets == -1)
                    break;
                dstring brackets = _text[current .. endOfBrackets];
                current = endOfBrackets + 1;

                foreach (modifier; brackets.split(",")) {
                    if (!modifier.length)
                        continue;
                    auto parameters = splitter(modifier, regex("[:=]"d));
                    if (parameters.empty)
                        continue;
                    const dstring cmd = parameters.front;
                    parameters.popFront();
                    switch (cmd) {
                    case "c":
                    case "color":
                        Token token;
                        token.type = Token.Type.color;
                        if (!parameters.empty) {
                            if (!parameters.front.length)
                                continue;
                            if (parameters.front[0] == '#') {
                                continue;
                                // TODO: #FFFFFF RGB color format
                            }
                            else {
                                switch (parameters.front) {
                                case "red":
                                    token.color.color = Color.red;
                                    break;
                                case "blue":
                                    token.color.color = Color.blue;
                                    break;
                                case "white":
                                    token.color.color = Color.white;
                                    break;
                                case "black":
                                    token.color.color = Color.black;
                                    break;
                                case "yellow":
                                    token.color.color = Color.yellow;
                                    break;
                                case "cyan":
                                    token.color.color = Color.cyan;
                                    break;
                                case "magenta":
                                    token.color.color = Color.magenta;
                                    break;
                                case "silver":
                                    token.color.color = Color.silver;
                                    break;
                                case "gray":
                                case "grey":
                                    token.color.color = Color.gray;
                                    break;
                                case "maroon":
                                    token.color.color = Color.maroon;
                                    break;
                                case "olive":
                                    token.color.color = Color.olive;
                                    break;
                                case "green":
                                    token.color.color = Color.green;
                                    break;
                                case "purple":
                                    token.color.color = Color.purple;
                                    break;
                                case "teal":
                                    token.color.color = Color.teal;
                                    break;
                                case "navy":
                                    token.color.color = Color.navy;
                                    break;
                                case "pink":
                                    token.color.color = Color.pink;
                                    break;
                                case "orange":
                                    token.color.color = Color.orange;
                                    break;
                                default:
                                    continue;
                                }
                            }
                        }
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    case "s":
                    case "scale":
                    case "size":
                    case "sz":
                        Token token;
                        token.type = Token.Type.scale;
                        if (!parameters.empty)
                            token.scale.scale = parameters.front.to!int;
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    case "l":
                    case "ln":
                    case "line":
                    case "br":
                        Token token;
                        token.type = Token.Type.line;
                        _tokens ~= token;
                        break;
                    case "w":
                    case "wait":
                    case "p":
                    case "pause":
                        Token token;
                        token.type = Token.Type.pause;
                        if (!parameters.empty)
                            token.pause.duration = parameters.front.to!float;
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    case "fx":
                    case "effect":
                        Token token;
                        token.type = Token.Type.effect;
                        token.effect.type = Token.EffectToken.Type.none;
                        if (!parameters.empty) {
                            switch (parameters.front) {
                            case "wave":
                                token.effect.type = Token.EffectToken.Type.wave;
                                break;
                            case "bounce":
                                token.effect.type = Token.EffectToken.Type.bounce;
                                break;
                            case "shake":
                                token.effect.type = Token.EffectToken.Type.shake;
                                break;
                            case "rainbow":
                                token.effect.type = Token.EffectToken.Type.rainbow;
                                break;
                            default:
                                token.effect.type = Token.EffectToken.Type.none;
                                break;
                            }
                        }
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    case "d":
                    case "dl":
                    case "delay":
                        Token token;
                        token.type = Token.Type.delay;
                        if (!parameters.empty)
                            token.delay.duration = parameters.front.to!float;
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    case "cps":
                        Token token;
                        token.type = Token.Type.delay;
                        if (!parameters.empty) {
                            const int cps = parameters.front.to!int;
                            token.delay.duration = (cps == 0) ? 0f : (1f / cps);
                        }
                        else
                            continue;
                        _tokens ~= token;
                        break;
                    default:
                        continue;
                    }
                }
            }
            else {
                Token token;
                token.type = Token.Type.character;
                token.character.character = _text[current];
                _tokens ~= token;
                current++;
            }
        }
        reload();
    }

    private void reload() {
        Vec2f totalSize_ = Vec2f(0f, _font.ascent - _font.descent);
        float lineWidth = 0f;
        dchar prevChar;
        int charSpacing_ = _charSpacing;
        int charScale_ = min(cast(int) scale.x, cast(int) scale.y);
        foreach (Token token; _tokens) {
            final switch (token.type) with (Token.Type) {
            case line:
                lineWidth = 0f;
                totalSize_.y += _font.lineSkip;
                break;
            case character:
                const Glyph metrics = _font.getMetrics(token.character.character);
                lineWidth += _font.getKerning(prevChar, token.character.character) * charScale_;
                lineWidth += (metrics.advance + charSpacing_) * charScale_;
                if (lineWidth > totalSize_.x)
                    totalSize_.x = lineWidth;
                prevChar = token.character.character;
                break;
            case charSpacing:
                charSpacing_ = token.charSpacing.charSpacing;
                break;
            case scale:
                charScale_ = token.scale.scale;
                break;
            case pause:
            case delay:
            case color:
            case effect:
                break;
            }
        }
        size = totalSize_;
    }

    override void update(float deltaTime) {
        _timer.update(deltaTime);
        _effectTimer.update(deltaTime);
    }

    override void draw() {
        Vec2f pos = origin;
        dchar prevChar;
        Color charColor_ = color;
        float charDelay_ = _delay;
        int charScale_ = min(cast(int) scale.x, cast(int) scale.y);
        int charSpacing_ = _charSpacing;
        Token.EffectToken.Type charEffect_ = Token.EffectToken.Type.none;
        Vec2f totalSize_ = Vec2f.zero;
        Timer waveTimer = _effectTimer;
        foreach (size_t index, Token token; _tokens) {
            final switch (token.type) with (Token.Type) {
            case character:
                if (_currentIndex == index) {
                    if (_timer.isRunning)
                        break;
                    if (charDelay_ > 0f)
                        _timer.start(charDelay_);
                    _currentIndex++;
                }
                Glyph metrics = _font.getMetrics(token.character.character);
                pos.x += _font.getKerning(prevChar, token.character.character) * charScale_;
                Vec2f drawPos = Vec2f(pos.x + metrics.offsetX * charScale_,
                        pos.y - metrics.offsetY * charScale_);

                final switch (charEffect_) with (Token.EffectToken.Type) {
                case none:
                    break;
                case wave:
                    waveTimer.update(1f);
                    waveTimer.update(1f);
                    waveTimer.update(1f);
                    waveTimer.update(1f);
                    waveTimer.update(1f);
                    waveTimer.update(1f);
                    if (waveTimer.value01 < .5f)
                        drawPos.y -= lerp!float(_font.descent, _font.ascent,
                                easeInOutSine(waveTimer.value01 * 2f));
                    else
                        drawPos.y -= lerp!float(_font.ascent, _font.descent,
                                easeInOutSine((waveTimer.value01 - .5f) * 2f));
                    break;
                case bounce:
                    if (_effectTimer.value01 < .5f)
                        drawPos.y -= lerp!float(_font.descent, _font.ascent,
                                easeOutSine(_effectTimer.value01 * 2f));
                    else
                        drawPos.y -= lerp!float(_font.ascent, _font.descent,
                                easeInSine((_effectTimer.value01 - .5f) * 2f));
                    break;
                case shake:
                    drawPos += Vec2f(uniform01(), uniform01()) * charScale_;
                    break;
                case rainbow:
                    break;
                }

                metrics.draw(drawPos, charScale_, charColor_, 1f);
                pos.x += (metrics.advance + charSpacing_) * charScale_;
                prevChar = token.character.character;
                if ((pos.x - origin.x) > totalSize_.x) {
                    totalSize_.x = (pos.x - origin.x);
                }
                if (((_font.ascent - _font.descent) * charScale_) > totalSize_.y) {
                    totalSize_.y = (_font.ascent - _font.descent) * charScale_;
                }
                break;
            case line:
                if (_currentIndex == index)
                    _currentIndex++;
                pos.x = origin.x;
                pos.y += _font.lineSkip * charScale_;
                if ((pos.y - origin.y) > totalSize_.y) {
                    totalSize_.y = (pos.y - origin.y);
                }
                break;
            case scale:
                if (_currentIndex == index)
                    _currentIndex++;
                charScale_ = token.scale.scale;
                break;
            case charSpacing:
                if (_currentIndex == index)
                    _currentIndex++;
                charSpacing_ = token.charSpacing.charSpacing;
                break;
            case color:
                if (_currentIndex == index)
                    _currentIndex++;
                charColor_ = token.color.color;
                break;
            case delay:
                if (_currentIndex == index)
                    _currentIndex++;
                charDelay_ = token.delay.duration;
                break;
            case pause:
                if (_currentIndex == index) {
                    if (_timer.isRunning)
                        break;
                    if (token.pause.duration > 0f)
                        _timer.start(token.pause.duration);
                    _currentIndex++;
                }
                break;
            case effect:
                if (_currentIndex == index)
                    _currentIndex++;
                charEffect_ = token.effect.type;
                break;
            }
            if (index == _currentIndex)
                break;
        }
    }
}

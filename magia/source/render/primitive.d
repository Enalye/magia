module render.primitive;

import std.string;
import bindbc.opengl, bindbc.sdl;
import core, render.window;

private {
    GLuint _shaderProgram, _vertShader, _fragShader;
    GLuint _vao;
    GLint _sizeUniform, _positionUniform, _rotUniform, _colorUniform;
}

void initPrimitive() {
    // Vertices
    immutable float[] points = [
        -1, 1f, 1f, -1f, -1f, -1f, -1f, 1f, 1, 1f, 1f, -1f,
    ];

    GLuint vbo = 0;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, points.length * float.sizeof, points.ptr, GL_STATIC_DRAW);

    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, null);
    glEnableVertexAttribArray(0);

    immutable char* vshader = toStringz("
        #version 400
        in vec2 vp;
        out vec2 st;
        uniform vec2 size;
        uniform vec2 position;
        uniform vec2 rot;
        void main() {
            vec2 rotated = vec2(vp.x * rot.x - vp.y * rot.y, vp.x * rot.y + vp.y * rot.x);
            rotated = (rotated + 1.0) * 0.5;
            gl_Position = vec4((position + (rotated * size)) * 2.0 - 1.0, 0.0, 1.0);
            st = ((vp + 1.0) * 0.5);
        }
        ");

    immutable char* fshader = toStringz("
        #version 400
        in vec2 st;
        out vec4 frag_color;
        uniform vec4 color;
        void main() {
            frag_color = color;
            if(frag_color.a == 0.0)
                discard;
        }
        ");

    _vertShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(_vertShader, 1, &vshader, null);
    glCompileShader(_vertShader);
    _fragShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(_fragShader, 1, &fshader, null);
    glCompileShader(_fragShader);

    _shaderProgram = glCreateProgram();
    glAttachShader(_shaderProgram, _fragShader);
    glAttachShader(_shaderProgram, _vertShader);
    glLinkProgram(_shaderProgram);
    _sizeUniform = glGetUniformLocation(_shaderProgram, "size");
    _positionUniform = glGetUniformLocation(_shaderProgram, "position");
    _rotUniform = glGetUniformLocation(_shaderProgram, "rot");
    _colorUniform = glGetUniformLocation(_shaderProgram, "color");
}

/// Draw a fully filled rectangle.
void drawFilledRect(Vec2f origin, Vec2f size, const Color color,
        float alpha = 1f, float angle = 0f) {
    origin = transformRenderSpace(origin) / screenSize();
    size = (size * transformScale()) / screenSize();

    glUseProgram(_shaderProgram);

    glUniform2f(_sizeUniform, size.x, size.y);
    glUniform2f(_positionUniform, origin.x, origin.y);
    glUniform4f(_colorUniform, color.r, color.g, color.b, alpha);

    const float radians = -angle * degToRad;
    const float c = std.math.cos(radians);
    const float s = std.math.sin(radians);
    glUniform2f(_rotUniform, c, s);
    glBindVertexArray(_vao);

    glEnable(GL_BLEND);
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ZERO, GL_ONE);
    glBlendEquation(GL_FUNC_ADD);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

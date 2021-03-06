module magia.script.sprite;

import grimoire;

import magia.core, magia.render;

package(magia.script) void loadMagiaLibSprite(GrLibrary library) {
    GrType spriteType = library.addForeign("Sprite", [], "Drawable");
    GrType textureType = grGetForeignType("Texture");

    library.addPrimitive(&_sprite1, "Sprite", [textureType], [spriteType]);
    library.addPrimitive(&_sprite2, "Sprite", [
            textureType, grInt, grInt, grInt, grInt
            ], [spriteType]);

    library.addPrimitive(&_setClip, "setClip", [
            spriteType, grInt, grInt, grInt, grInt
            ]);
    library.addPrimitive(&_getClip, "getClip", [], [
            spriteType, grInt, grInt, grInt, grInt
            ]);

    library.addPrimitive(&_getWidth, "getWidth", [spriteType], [grFloat]);
    library.addPrimitive(&_getHeight, "getHeight", [spriteType], [grFloat]);
    library.addPrimitive(&_getHeight, "getSize", [spriteType], [grFloat, grFloat]);
}

private void _sprite1(GrCall call) {
    Sprite sprite = new Sprite(call.getForeign!Texture(0));
    call.setForeign(sprite);
}

private void _sprite2(GrCall call) {
    Sprite sprite = new Sprite(call.getForeign!Texture(0),
            Vec4i(call.getInt(1), call.getInt(2), call.getInt(3), call.getInt(4)));
    call.setForeign(sprite);
}

private void _setClip(GrCall call) {
    Sprite sprite = call.getForeign!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    sprite.clip = Vec4i(call.getInt(1), call.getInt(2), call.getInt(3), call.getInt(4));
}

private void _getClip(GrCall call) {
    Sprite sprite = call.getForeign!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }

    call.setInt(sprite.clip.x);
    call.setInt(sprite.clip.y);
    call.setInt(sprite.clip.z);
    call.setInt(sprite.clip.w);
}

private void _getWidth(GrCall call) {
    Sprite sprite = call.getForeign!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    call.setFloat(sprite.size.x);
}

private void _getHeight(GrCall call) {
    Sprite sprite = call.getForeign!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    call.setFloat(sprite.size.y);
}

private void _getSize(GrCall call) {
    Sprite sprite = call.getForeign!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    call.setFloat(sprite.size.x);
    call.setFloat(sprite.size.y);
}

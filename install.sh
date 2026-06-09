#!/bin/bash
DOTFILES="$HOME/ReaderOS/dotfiles"
CONFIG="$HOME/.config"
LOCAL_BIN="$HOME/.local/bin"

mkdir -p "$CONFIG" "$LOCAL_BIN"

echo ":: Linking configs..."
for dir in "$DOTFILES/.config"/*/; do
    name=$(basename "$dir")
    rm -rf "$CONFIG/$name"
    ln -sf "${dir%/}" "$CONFIG/$name"
    echo "   linked $name"
done

echo ":: Linking scripts..."
for file in "$DOTFILES/.local/bin"/*; do
    name=$(basename "$file")
    rm -f "$LOCAL_BIN/$name"
    ln -sf "$file" "$LOCAL_BIN/$name"
    echo "   linked $name"
done

echo ":: Done."

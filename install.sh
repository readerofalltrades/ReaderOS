#!/bin/bash

DOTFILES="$HOME/ReaderOS/dotfiles"
CONFIG="$HOME/.config"
LOCAL_BIN="$HOME/.local/bin"

echo ":: Linking configs..."

for dir in "$DOTFILES/.config"/*/; do
    name=$(basename "$dir")
    ln -sf "${dir%/}" "$CONFIG/$name"
    echo "   linked $name"
done

echo ":: Linking scripts..."
for file in "$DOTFILES/.local/bin"/*; do
    name=$(basename "$file")
    ln -sf "$file" "$LOCAL_BIN/$name"
    echo "   linked $name"
done

echo ":: Done."

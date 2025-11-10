#!/bin/bash

# Define um perfil separado para o Notion não bagunçar seu Chrome principal
CHROME_PROFILE="$HOME/.config/google-chrome-notion"

# Lança o Chrome em modo "app", com um perfil separado
#
# A PARTE MAIS IMPORTANTE:
# O comando '--class="NotionApp"' força a janela a ter um nome que o i3 possa identificar.
# Isso é muito mais fácil do que adivinhar com o xprop.
#
google-chrome \
    --user-data-dir="$CHROME_PROFILE" \
    --app="https://notion.so" \
    --class="NotionApp"

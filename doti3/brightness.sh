#!/bin/bash

# --- Configuração Universal ---
# A opção '-c backlight' diz para o programa ignorar LEDs de teclado/mouse
# e focar apenas no monitor. Funciona para Intel, AMD e Nvidia.
OPTS="-c backlight"

# Pega o brilho atual (sem %)
# O '-m' gera saída em formato de máquina (nome,classe,brilho,porcentagem,...)
OLD_VAL=$(brightnessctl $OPTS -m | cut -d, -f4 | tr -d %)

case $1 in
    "+")
        brightnessctl $OPTS set +5% -q
        ;;
    "-")
             brightnessctl $OPTS set 5%- -q
        ;;
    *)
        # Para definir valor fixo direto (ex: ./script 100)
        brightnessctl $OPTS set $1% -q
        ;;
esac

# Pega o novo valor para a notificação
NEW_VAL=$(brightnessctl $OPTS -m | cut -d, -f4 | tr -d %)

# Envia a notificação visual
# O ID 991050 impede que as notificações se empilhem (uma substitui a outra)
dunstify -a "brightness" -u low -r 991050 -h int:value:"$NEW_VAL" "Brilho: ${NEW_VAL}%" -t 1500

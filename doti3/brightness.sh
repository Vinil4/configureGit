#!/bin/bash

# --- Configuração Universal ---
OPTS="-c backlight"

# --- Lógica de Comandos ---
case $1 in
    "up")
        # Aumenta 5%
        brightnessctl $OPTS set +5% -q
        ;;
    "down")
        # Diminui 5%, mas não deixa baixar de 1% (pra não apagar a tela totalmente)
        # O brightnessctl geralmente protege isso, mas é bom garantir.
        brightnessctl $OPTS set 5%- -q
        ;;
    "min")
        # Define para o mínimo (1% é mais seguro que 0%)
        brightnessctl $OPTS set 1% -q
        ;;
    "max")
        # Define para o máximo
        brightnessctl $OPTS set 100% -q
        ;;
    *)
        # Caso você queira passar um número direto (ex: ./script 50)
        # Verifica se o argumento é um número
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            brightnessctl $OPTS set $1% -q
        fi
        ;;
esac

# --- Notificação ---
# Pega o novo valor ATUALIZADO
NEW_VAL=$(brightnessctl $OPTS -m | cut -d, -f4 | tr -d %)

# Envia a notificação
dunstify -a "brightness" -u low -r 991050 -h int:value:"$NEW_VAL" "Brilho: ${NEW_VAL}%" -t 1500


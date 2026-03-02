#!/bin/bash

# Script per la creazione automatica di immagini ISO da /dev/sr0 su Debian.
# Requisiti: Dispositivo ottico su /dev/sr0, permessi sudo.

ISO_NAME=""
ISO_DIR="$HOME/GiochiPS2"
DEVICE="/dev/sr0"
MOUNT_POINT="/mnt/ps2disk"

echo "=================================================="
echo "💿 Creazione Immagine ISO PS2 da $DEVICE"
echo "=================================================="

# 1. Chiedi il nome del gioco
while [ -z "$ISO_NAME" ]; do
    read -p "Inserisci il nome del gioco (es. 'Budokai_Tenkaichi_3'): " ISO_NAME
    if [ -z "$ISO_NAME" ]; then
        echo "⚠️ Il nome non può essere vuoto."
    fi
done

# 2. Crea la directory di destinazione se non esiste
if [ ! -d "$ISO_DIR" ]; then
    echo "⚙️ Creazione della cartella di destinazione: $ISO_DIR"
    mkdir -p "$ISO_DIR"
    if [ $? -ne 0 ]; then
        echo "❌ ERRORE: Impossibile creare la directory $ISO_DIR. Esco."
        exit 1
    fi
fi

# 3. Smonta il dispositivo se montato
if mount | grep -q "$MOUNT_POINT"; then
    echo "🔄 Smontaggio del punto di mount $MOUNT_POINT..."
    sudo umount "$MOUNT_POINT"
    if [ $? -ne 0 ]; then
        echo "❌ ERRORE: Impossibile smontare $MOUNT_POINT. Esco."
        exit 1
    fi
fi

# 4. Copia il disco in formato ISO con dd
OUTPUT_FILE="$ISO_DIR/$ISO_NAME.iso"
echo ""
echo "⏳ Avvio copia: $DEVICE -> $OUTPUT_FILE"
echo "   (Questo processo non mostra progressi e può durare diversi minuti.)"
echo ""

# Uso di sudo per garantire i permessi di lettura da /dev/sr0
sudo dd if="$DEVICE" of="$OUTPUT_FILE" bs=2048 conv=notrunc status=progress 2>&1 | grep --line-buffered -E '^\s*[0-9]+'
# Nota: "status=progress" è per versioni di dd più recenti, se non funziona 
# (es. su vecchie Debian) rimuovi l'opzione status=progress e non vedrai l'indicatore.

if [ $? -eq 0 ]; then
    echo ""
    echo "=================================================="
    echo "✅ COPIA COMPLETATA!"
    echo "Il file ISO è stato salvato qui: $OUTPUT_FILE"
    echo "Ora puoi caricarlo su PCSX2."
    echo "=================================================="
else
    echo ""
    echo "=================================================="
    echo "❌ ERRORE CRITICO DURANTE LA COPIA (dd non riuscito)."
    echo "Assicurati che il disco sia pulito e inserito correttamente."
    echo "=================================================="
    exit 1
fi

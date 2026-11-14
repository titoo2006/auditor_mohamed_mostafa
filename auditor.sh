#!/bin/bash
# auditor.sh - file auditor and backup tool

source ./lib.sh

DIR="${1:-.}"
ACTION="$2"
BACKUP_DIR="./backups"

# list every file and folder and count them
scan_directory() {
    local dir="$1"
    local files=0
    local folders=0
    local f

    for f in "$dir"/*; do
        [ -e "$f" ] || continue
        if [ -f "$f" ]; then
            echo "[file] $(basename "$f")"
            files=$((files + 1))
        elif [ -d "$f" ]; then
            echo "[dir ] $(basename "$f")"
            folders=$((folders + 1))
        fi
    done

    echo "Files: $files Folders: $folders"
    log_action "scan $dir"
}

# show read, write and execute flags of every file and count problems
permission_audit() {
    local dir="$1"
    local unreadable=0
    local executable=0
    local f
    local flags

    for f in "$dir"/*; do
        [ -f "$f" ] || continue
        flags=""

        if [ -r "$f" ]; then flags="${flags}r"; else flags="${flags}-"; fi
        if [ -w "$f" ]; then flags="${flags}w"; else flags="${flags}-"; fi
        if [ -x "$f" ]; then flags="${flags}x"; else flags="${flags}-"; fi

        echo "$flags $(basename "$f")"

        [ ! -r "$f" ] && unreadable=$((unreadable + 1))
        [ -x "$f" ] && executable=$((executable + 1))
    done

    echo "Unreadable files: $unreadable Executable files: $executable"
    log_action "permission audit $dir"
}

# count the files of each extension using an associative array
extension_report() {
    local dir="$1"
    local f
    local ext
    local key
    declare -A count

    count[txt]=0
    count[log]=0
    count[sh]=0
    count[jpg]=0
    count[other]=0

    for f in "$dir"/*; do
        [ -f "$f" ] || continue
        ext="${f##*.}"

        if [ "$ext" = "txt" ]; then
            count[txt]=$((count[txt] + 1))
        elif [ "$ext" = "log" ]; then
            count[log]=$((count[log] + 1))
        elif [ "$ext" = "sh" ]; then
            count[sh]=$((count[sh] + 1))
        elif [ "$ext" = "jpg" ]; then
            count[jpg]=$((count[jpg] + 1))
        else
            count[other]=$((count[other] + 1))
        fi
    done

    for key in "${!count[@]}"; do
        echo "$key : ${count[$key]}"
    done

    log_action "extension report $dir"
}

# ask for a text and print every file whose name contains it
search_file() {
    local dir="$1"
    local text
    local f
    local name
    local found=0

    read -p "Enter text to search for: " text

    for f in "$dir"/*; do
        [ -f "$f" ] || continue
        name=$(basename "$f")
        if [[ "$name" == *"$text"* ]]; then
            echo "$name"
            found=$((found + 1))
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo "No file matches '$text'"
    fi
    log_action "search '$text' in $dir"
}

# copy every readable file to the backups folder with date and time in its name
backup_all() {
    local dir="$1"
    local f
    local name
    local stamp
    local saved=0
    local skipped=0

    mkdir -p "$BACKUP_DIR"
    stamp=$(date +%Y%m%d_%H%M%S)

    for f in "$dir"/*; do
        [ -f "$f" ] || continue
        name=$(basename "$f")
        if [ -r "$f" ]; then
            cp "$f" "$BACKUP_DIR/${name}_${stamp}.bak"
            saved=$((saved + 1))
        else
            log_error "cannot read $name, skipped"
            skipped=$((skipped + 1))
        fi
    done

    echo "Saved: $saved Skipped: $skipped"
    log_action "backup $dir saved=$saved skipped=$skipped"
}

# print the names of the saved backups
list_backups() {
    local line
    local count=0

    if [ -d "$BACKUP_DIR" ]; then
        while read -r line; do
            echo "$line"
            count=$((count + 1))
        done < <(ls "$BACKUP_DIR")
    fi

    if [ "$count" -eq 0 ]; then
        echo "(no backups yet)"
    fi
    log_action "list backups"
}

# copy a backup back to the folder as restored_NAME, never overwriting
restore_backup() {
    local dir="$1"
    local name="$2"
    local target="$dir/restored_$name"

    if [ ! -f "$BACKUP_DIR/$name" ]; then
        log_error "backup $name does not exist"
        log_action "restore failed: $name not found"
        return 1
    fi

    if [ -e "$target" ]; then
        log_error "$target already exists, not overwriting"
        log_action "restore failed: $target exists"
        return 1
    fi

    cp "$BACKUP_DIR/$name" "$target"
    echo "Restored to $target"
    log_action "restore $name to $target"
}

# temporary main part, only for testing
require_dir "$DIR"
# ask for a text and print every file whose name contains it
search_file() {
    local dir="$1"
    local text
    local f
    local name
    local found=0

    read -p "Enter text to search for: " text

    for f in "$dir"/*; do
        [ -f "$f" ] || continue
        name=$(basename "$f")
        if [[ "$name" == *"$text"* ]]; then
            echo "$name"
            found=$((found + 1))
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo "No file matches '$text'"
    fi
    log_action "search '$text' in $dir"
}

# copy every readable file to the backups folder with date and time in its name
backup_all() {
    local dir="$1"
    local f
    local name
    local stamp
    local saved=0
    local skipped=0

    mkdir -p "$BACKUP_DIR"
    stamp=$(date +%Y%m%d_%H%M%S)

    for f in "$dir"/*; do
        [ -f "$f" ] || continue
        name=$(basename "$f")
        if [ -r "$f" ]; then
            cp "$f" "$BACKUP_DIR/${name}_${stamp}.bak"
            saved=$((saved + 1))
        else
            log_error "cannot read $name, skipped"
            skipped=$((skipped + 1))
        fi
    done

    echo "Saved: $saved Skipped: $skipped"
    log_action "backup $dir saved=$saved skipped=$skipped"
}

# print the names of the saved backups
list_backups() {
    local line
    local count=0

    if [ -d "$BACKUP_DIR" ]; then
        while read -r line; do
            echo "$line"
            count=$((count + 1))
        done < <(ls "$BACKUP_DIR")
    fi

    if [ "$count" -eq 0 ]; then
        echo "(no backups yet)"
    fi
    log_action "list backups"
}

# copy a backup back to the folder as restored_NAME, never overwriting
restore_backup() {
    local dir="$1"
    local name="$2"
    local target="$dir/restored_$name"

    if [ ! -f "$BACKUP_DIR/$name" ]; then
        log_error "backup $name does not exist"
        log_action "restore failed: $name not found"
        return 1
    fi

    if [ -e "$target" ]; then
        log_error "$target already exists, not overwriting"
        log_action "restore failed: $target exists"
        return 1
    fi

    cp "$BACKUP_DIR/$name" "$target"
    echo "Restored to $target"
    log_action "restore $name to $target"
}

# show the menu in a loop until the user chooses Exit
show_menu() {
    local choice
    local name

    while true; do
        echo ""
        echo "===== File Auditor ====="
        echo "1) Scan directory"
        echo "2) Permission audit"
        echo "3) Extension report"
        echo "4) Search file"
        echo "5) Backup all"
        echo "6) List backups"
        echo "7) Restore backup"
        echo "8) Exit"
        read -p "Choose: " choice

        case "$choice" in
            1) scan_directory "$DIR" ;;
            2) permission_audit "$DIR" ;;
            3) extension_report "$DIR" ;;
            4) search_file "$DIR" ;;
            5) backup_all "$DIR" ;;
            6) list_backups ;;
            7)
                list_backups
                read -p "Backup name to restore: " name
                restore_backup "$DIR" "$name"
                ;;
            8) echo "Bye"; break ;;
            *) log_error "wrong choice, try again" ;;
        esac
    done
}

# main part: check the folder, then run one action or open the menu
require_dir "$DIR"

if [ "$ACTION" = "scan" ]; then
    scan_directory "$DIR"
elif [ "$ACTION" = "perms" ]; then
    permission_audit "$DIR"
elif [ "$ACTION" = "ext" ]; then
    extension_report "$DIR"
elif [ "$ACTION" = "backup" ]; then
    backup_all "$DIR"
elif [ -z "$ACTION" ]; then
    show_menu
else
    log_error "unknown action '$ACTION' (use scan, perms, ext or backup)"
    exit 1
fi

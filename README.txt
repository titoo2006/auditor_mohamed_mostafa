File Auditor & Backup Tool
Bash mini project - Operating Systems, Alexandria National University

Team: Mohamed mostafa mohamed 2406237

Who did what:
- Mohamed Mostafa Mohamed: lib.sh, scan, permission audit, extension report, search, backup,
 list backups, restore, menu, command-line part.

Files:
- auditor.sh : main script (functions, menu, command-line part)
- lib.sh     : helper functions (log_info, log_error, log_action, require_dir)

How to run (from inside the script folder):
  chmod +x auditor.sh lib.sh
  ./auditor.sh <folder>            opens the menu
  ./auditor.sh <folder> scan       list files and folders
  ./auditor.sh <folder> perms      permission audit
  ./auditor.sh <folder> ext        extension report
  ./auditor.sh <folder> backup     back up all readable files
If no folder is given, the current folder is used.

Notes:
- Backups are saved in ./backups as name_YYYYMMDD_HHMMSS.bak
- Restore copies a backup to the audited folder as restored_<backup name>
  and never overwrites an existing file.
- Every action writes one line to auditor.log.

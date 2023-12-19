#!/bin/bash
POSTGRES_CONTAINER_NAME="postgres"

# Define the backup directory
BACKUP_DIR="/backup/db"

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Define the backup file name with the current date
BACKUP_FILE="$BACKUP_DIR/backup-db-$(date +%d-%m-%y-h-%H).sql"

# Run the pg_dumpall command inside the Docker container
sudo docker exec -t "$POSTGRES_CONTAINER_NAME" pg_dumpall -U postgres > "$BACKUP_FILE"

echo "Database backup created at $BACKUP_FILE"

# Remove older backup files, keeping only the last 5
cd "$BACKUP_DIR" || exit
ls -t backup-db-*.sql | tail -n +11 | xargs rm -f

tar -czvf /backup/db/backup-db-$(date +%d-%m-%y-h-%H).tar.gz backup-db-$(date +%d-%m-%y-h-%H).sql

s3cmd put /backup/db/backup-db-$(date +%d-%m-%y-h-%H).tar.gz s3://<path_to_storage>/<subDirestories>/

s3cmd del s3://<path_to_storage>/<subDirestories>/backup-db-$(date -d '3 day ago' +%d-%m-%y-h-%H).tar.gz

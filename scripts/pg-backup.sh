#!/usr/bin/env bash

# Set variables
TEMP_DIR="/tmp/postgres_backups"
FINAL_BACKUP_DIR="/mnt/pgdumps"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_RETENTION_DAYS=7
TEMP_LOG_FILE="/tmp/postgres_backup_$(date +"%Y%m%d").log"
LOG_FILE="/var/log/postgres_backup_$(date +"%Y%m%d").log"

# Databases to backup (comma-separated)
DATABASE_LIST="nextcloud"

# Function for logging
log_message() {
	echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Error handling function
handle_error() {
	log_message "ERROR: $1"
	exit 1
}

# Create directories
mkdir -p "$TEMP_DIR" || handle_error "Failed to create temp directory $TEMP_DIR"
chmod 777 "$TEMP_DIR" || handle_error "Failed to set permissions on $TEMP_DIR"
mkdir -p "$FINAL_BACKUP_DIR" || handle_error "Failed to create backup directory $FINAL_BACKUP_DIR"

log_message "Starting PostgreSQL backup process"

# Check if we can communicate with PostgreSQL
if ! su - postgres -c "psql -c '\l' >/dev/null 2>&1"; then
	handle_error "Cannot connect to PostgreSQL server"
fi

# Backup each database separately
for DB in ${DATABASE_LIST//,/ }; do
	log_message "Backing up database: $DB"

	# Create folder for database
	mkdir -p "$TEMP_DIR/$DB" || handle_error "Failed to create $TEMP_DIR/$DB"
	mkdir -p "$FINAL_BACKUP_DIR/$DB" || handle_error "Failed to create $FINAL_BACKUP_DIR/$DB"
	chmod 777 "$TEMP_DIR/$DB"

	BCKP_FILENAME="$DB-${TIMESTAMP}.sql.gz"
	TEMP_BCKP_PATH="$TEMP_DIR/$DB/$BCKP_FILENAME"

	# Create SQL file and pipe directly to gzip
	if su - postgres -c "pg_dump -F p -v \"$DB\" 2>>$TEMP_LOG_FILE | gzip -9 > \"$TEMP_BCKP_PATH\""; then
		# Check if file size is greater than 0
		if [ -s "$TEMP_BCKP_PATH" ]; then
			cp "$TEMP_BCKP_PATH" "$FINAL_BACKUP_DIR/$DB/" || handle_error "Failed to copy $DB backup to final destination"
			sudo cat "$TEMP_LOG_FILE" | sudo tee -a "$LOG_FILE"
			log_message "Backup of $DB completed successfully: $(du -h "$TEMP_BCKP_PATH" | cut -f1)"
		else
			handle_error "Backup file for $DB is empty"
		fi
	else
		handle_error "Backup of $DB failed"
	fi
done

log_message "Cleaning up old backups (older than $BACKUP_RETENTION_DAYS days)"

# Clean up old backups
for DB in ${DATABASE_LIST//,/ }; do
	find "$FINAL_BACKUP_DIR/$DB" -name "*.sql.gz" -type f -mtime +$BACKUP_RETENTION_DAYS -delete
	COUNT=$(find "$FINAL_BACKUP_DIR/$DB" -name "*.sql.gz" -type f | wc -l)
	log_message "Kept $COUNT backup(s) for $DB"
done

# Clean up temporary files
rm -rf "$TEMP_DIR"
log_message "Backup process completed successfully"

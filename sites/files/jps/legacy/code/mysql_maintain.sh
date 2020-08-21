# 2007-08-21 JPS
#
# Insert the following lines in your ~/.bashrc file, and you should 
# then be able to use mysql_maintain and mysql_maintain_copy .
#
# Run ". ~/.bashrc" to refresh your config if you've just edited .bashrc

# Backup and restore functionality
function mysql_maintain
{
    # Check required args
    for arg in "$1" "$2"
    do
        if [ -z "$arg" ]; then
            mysql_maintain_usage
            return
        fi
    done
    op=$1
    db=$2

    # Dir arg?
    dir=$3
    if [ -z "$dir" ]; then
        dir=~
    fi

    # File arg?
    file=$4
    if [ -z "$file" ]; then
        file=db_$2_`date +%Y%m%dT%H.sql.gz`
    fi

    # Switch on operation
    case "${op:0:1}" in
        b)
            # Back up using mysqldump, adding drop tables
            mysqldump --add-drop-table -u root -p "$db" | gzip -c > "$dir/$file"
            ;;
        r)
            # Restore by piping file into mysql
            gunzip -c "$dir/$file" | mysql -u root -p "$db"
            ;;
        *)
            # Show usage notes
            drupal_db_usage
            ;;
    esac

}

# Copy functionality, using a two-stage backup and restore via a temporary file
function mysql_maintain_copy
{
    # Check required args
    for arg in "$1" "$2"
    do
        if [ -z "$arg" ]; then
            mysql_maintain_usage
            return
        fi
    done

    # Get a random temporary filename using PID=$$
    file=db_drupal_copy_$1_$2_$$.sql.tgz
    dir=/tmp
    # Dump database
    mysql_maintain b "$1" "$dir" "$file"
    # Restore database
    mysql_maintain r "$2" "$dir" "$file"
    # Get rid of temp file
    rm "$dir/$file"
}

# Usage documentation
function mysql_maintain_usage
{
    echo "Usage:"
    echo "mysql_maintain ( backup | restore ) db_name [dir] [file]"
    echo "mysql_maintain_copy db_from db_to"
}


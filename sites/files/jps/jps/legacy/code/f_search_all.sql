-- @description Search the whole of a PostgreSQL database for a piece of text
-- @author J-P Stacey
-- @created 2006-03-27

DROP FUNCTION f_search_all(varchar(50));
DROP TYPE type_search_all;

-- Type
CREATE TYPE type_search_all AS (
    table_name varchar,
    column_name varchar,
    column_value varchar
);

-- Function
CREATE FUNCTION f_search_all(varchar(50)) 
    RETURNS setof type_search_all AS '

    DECLARE
        pg_row        record;
        table_name     pg_class.relname%type;
        table_row    record;
        table_oid    int4;
        column_name    record;
        return_me    type_search_all;
        column_content    record;
        column_searchable boolean;

    BEGIN
        -- Get all table names from pg_class
        FOR pg_row IN SELECT c.relname, c.oid AS pg_oid
            FROM
                pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_user u
                ON u.usesysid = c.relowner
                    LEFT JOIN pg_catalog.pg_namespace n
                ON n.oid = c.relnamespace
            WHERE
                c.relkind IN (''r'','''')
                AND
                n.nspname NOT IN (''pg_catalog'', ''pg_toast'')
                AND
                pg_catalog.pg_table_is_visible(c.oid)
        LOOP

            -- For each table, determine its columns
            table_name := pg_row.relname;
            table_oid = pg_row.pg_oid;
            FOR column_name IN SELECT attname,
                pg_catalog.format_type(atttypid, atttypmod) AS type
                FROM pg_catalog.pg_attribute
                WHERE
                    attrelid = table_oid
                    AND
                    attnum > 0
                    AND
                    NOT attisdropped
            LOOP

                -- For each column, check searchable -
                -- otherwise get errors off some data types
                column_searchable = CASE
                    WHEN column_name.type LIKE ''character varying%'' THEN true
                    WHEN column_name.type LIKE ''text'' THEN true
                    ELSE false
                END;

                -- If so, then search!
                IF column_searchable
                THEN
                    -- Grab the whole column and loop over it
                    FOR column_content IN
                        EXECUTE ''SELECT '' || column_name.attname ||
                            ''::text AS to_search, '' || column_name.attname ||
                            ''::varchar(3630) AS sample FROM '' || table_name
                    LOOP
                        -- At each successful LIKE, return the datatyped record
                        IF column_content.to_search LIKE ''%'' || $1 || ''%''
                        THEN
                            return_me.table_name = table_name;
                            return_me.column_name = column_name.attname;
                            return_me.column_value = column_content.sample;

                            RETURN NEXT return_me;
                        END IF;
                    END LOOP;
                END IF;

            END LOOP;

        END LOOP;

        -- A final return for "no more output"
        RETURN;
    END
' language 'plpgsql';

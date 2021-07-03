TYPE FATFS_FILE extends VFS_FILE_DESCRIPTOR field = 1 
    WRITEABLE           as unsigned integer
    TRUNCATE            as unsigned integer
    DIRECTORY_CLUSTER   as unsigned integer
    FILE_CLUSTER        as unsigned integer
    CURRENT_CLUSTER     as unsigned integer
    NEXT_CLUSTER        as unsigned integer
    
    FAT_FILENAME(0 to 10)   as unsigned byte
    DIRTY               as unsigned integer
    FPOS_IN_CLUSTER     as unsigned integer
    CLUSTER_SIZE        as unsigned integer
    CLUSTER_PAGES       as unsigned integer
    CLUSTER             as unsigned byte ptr
    FS                  as FATFS_DESCRIPTOR ptr
    
    declare sub CLOSE()
    declare function WRITE(count as unsigned integer,src as unsigned byte ptr) as unsigned integer
    declare function READ(count as unsigned integer,dest as  unsigned byte ptr) as unsigned integer
    declare sub LOAD_CLUSTER()     
    declare sub WRITE_CLUSTER()
end type
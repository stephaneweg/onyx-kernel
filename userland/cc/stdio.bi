
#define SIZEOF_FILE	32		'// sizeof (FILE)

#define stdin  0            '//(&_iob[0])
#define stdout 1            '//(&_iob[1*SIZEOF_FILE])
#define stderr 2            '//(&_iob[2*SIZEOF_FILE])

#define stdaux   3          '/* file descriptor for standard auxiliary port */
#define stdprn   4          '/* file descriptor for standard printer */
#define _FILE  byte          '/* supports "FILE *fp;" declarations */
#define _ERR   (-2)          '/* return value for errors */
#define __EOF   (-1)          '/* return value for end-of-file */
#define _NULL     0          '/* zero */

#!/bin/bash
scriptf=$1                         # capture the first parameter
printf "$scriptf \n\n"             # print it as header in output file

/usr/bin/time -v Rscript $scriptf  `# measure time to run script $scriptf` \
 2>&1 >/dev/null |                 `#redirect output to null and tee to` \
 grep -E 'Maximum resident'        `# grab this line`

time for i in {1..10}; do Rscript $scriptf >/dev/null; done

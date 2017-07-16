#!/bin/bash

# Find a list of services to restart when OpenSSL libraries are updated.
ctids=( 
	$(for i in `pgrep -z $(zonename)`; do \
		pldd $i 2>&1 | \
		egrep -e 'lib(ssl|crypto).so' >/dev/null && \
		ps -octid -p $i | \
		sed -e '1d; s/[^0-9]//g;' ; done | \
		sort -n | uniq)
       )

length=`expr ${#ctids[@]} - 1`
elems=$(eval echo {0..$length})

for index in $elems; do \
	svcs -o fmri,ctid -a | egrep "[^0-9]${ctids[$index]}$" | awk '{ print $1 }'
done

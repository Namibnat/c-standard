#!/bin/sh

export LC_ALL=C
sed 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g' | awk '
BEGIN {
	getline
	print "<html><head><title>" $0 "</title></head><body><pre>"
	print

	while (getline == 1) {
		if ($0 ~ /^Contents/)
			break
		print
	}
	print "<a name=\"Contents\" href=\"#Contents\">Contents</a>"

	while (getline == 1) {
		id = $1
		if (id ~ /Annex/)
			id = $2
		if (id ~ /^([1-9A-Z]|Index|Foreword|Introduction|Bibliography)/) {
			if (match($0, /&lt;[a-zA-Z0-9_]*\.h&gt;/)) {
				h=substr($0,RSTART,RLENGTH)
				if (!(h in header))
					header[h] = id
			}
			if (id ~ /\.$/)
				id = substr(id,1,length(id)-1)
			s = "<a href=\"#" id "\">" $0
			if ($(NF-1) == ".")
				print s "</a>"
			else{
				print s
				getline
				print $0 "</a>"
			}
			if (id == "Index")
				break
		} else
			print
	}
}

!seenindex && /^ *([1-9A-Z]\.|Annex|Index|Foreword|Introduction|Bibliography)/ {
	id = $1
	if (id ~ /Annex/)
		id = $2
	if (($0 ~ /^    [1-9]\./ || id ~ /^([A-Z]|[1-9A-Z]\.[1-9][0-9.]*|Index|Foreword|Introduction|Bibliography)$/) &&
	    (NF==1 || $2 ~ /^[A-Z]/)) {
		if (id ~ /\.$/)
			id = substr(id,1,length(id)-1)
		print "<a name=\"" id "\" href=\"#" id "\"><b>" $0 "</b></a>"
		if (id == "Index")
			seenindex=1
		next
	}
}

/^\[page / {
	p = substr($2,1,length($2)-1)
	print "[<a name=\"#p" p "\" href=\"p" p "\">page " p "</a>] (<a href=\"#Contents\">Contents</a>)"
	next
}

{
	s = $0
	p = ""
	if (seenindex)
		r = "[ (][A-Z1-9][0-9.]*"
	else
		r = "[ (][A-Z1-9]\\.[0-9.]*[0-9]"
	while (match(s, r)) {
		p = p substr(s,1,RSTART)
		m = substr(s,RSTART+1,RLENGTH-1)
		if (m ~ /[4-9][0-9]/ || m ~ /[0-3][0-9][0-9]/ || substr(s,RSTART+RLENGTH,1) ~ /[a-zA-Z\-]/)
			p = p m
		else
			p = p "<a href=\"#" m "\">" m "</a>"
		s = substr(s,RSTART+RLENGTH)
	}
	s = p s
	p = ""
	while (match(s, /[Aa]nnex [A-Z]/)) {
		p = p substr(s,1,RSTART-1)
		m = substr(s,RSTART,RLENGTH)
		p = p "<a href=\"#" substr(m,RLENGTH,1) "\">" m "</a>"
		s = substr(s,RSTART+RLENGTH)
	}
	s = p s
	p = ""
	while (match(s, /&lt;[a-zA-Z0-9_]*\.h&gt;/)) {
		p = p substr(s,1,RSTART-1)
		m = substr(s,RSTART,RLENGTH)
		if (m in header)
			p = p "<a href=\"#" header[m] "\">" m "</a>"
		else
			p = p m
		s = substr(s,RSTART+RLENGTH)
	}
	print p s
}

END { print "</pre></body></html>" }'
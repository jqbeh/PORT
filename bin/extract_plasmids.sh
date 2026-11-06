#!/usr/bin/env bash
#
# extract_plasmids.sh — write each putative plasmid contig of an assembly to
# its own FASTA file.
#
# A contig is kept when it is
#   * circular (header tag circular=true / circular=Y / circular=yes, any case;
#     Autocycler writes circular=true, Dragonflye writes circular=Y), and
#   * >= MIN_LEN bp and < MAX_LEN bp (length is counted from the sequence itself,
#     not taken from the header).
#
# Kept contigs are numbered in the order they appear in the assembly:
#   <isolate_id>.p1.fasta, <isolate_id>.p2.fasta, ...
# The header of each file becomes ">ISOLATE.pN" followed by the original header
# text, so the source contig can always be traced, e.g.
#   >AUSMDU00123.p1 1 length=135545 circular=true
#
# A summary table <isolate_id>_plasmids.tsv is always written (header only when
# no plasmid passes the filters).
#
# Usage:
#   extract_plasmids.sh <assembly.fasta> <isolate_id> [min_len=1000] [max_len=500000]

set -euo pipefail

assembly=${1:-}
isolate=${2:-}
min_len=${3:-1000}
max_len=${4:-500000}

if [[ -z "$assembly" || -z "$isolate" ]]; then
    echo "Usage: $0 <assembly.fasta> <isolate_id> [min_len] [max_len]" 1>&2
    exit 1
fi
if [[ ! -s "$assembly" ]]; then
    echo "Error: assembly '$assembly' does not exist or is empty." 1>&2
    exit 1
fi
if ! [[ "$min_len" =~ ^[0-9]+$ && "$max_len" =~ ^[0-9]+$ ]] || (( min_len >= max_len )); then
    echo "Error: min_len ($min_len) and max_len ($max_len) must be integers with min_len < max_len." 1>&2
    exit 1
fi

# Read gzipped or plain FASTA; strip Windows line endings.
if [[ "$assembly" == *.gz ]]; then reader=(gzip -dc "$assembly"); else reader=(cat "$assembly"); fi

"${reader[@]}" | tr -d '\r' | awk \
    -v isolate="$isolate" -v min_len="$min_len" -v max_len="$max_len" '
    BEGIN {
        OFS = "\t"
        summary = isolate "_plasmids.tsv"
        print "isolate_id", "plasmid_id", "original_contig", "length", "file" > summary
        n = 0
    }

    function flush(   id, lc, out, i) {
        if (header == "") return
        lc = tolower(header)
        if (lc ~ /(^|[ \t])circular=(true|y|yes)([ \t]|$)/ && len >= min_len + 0 && len < max_len + 0) {
            n++
            id  = isolate ".p" n
            out = id ".fasta"
            print ">" id " " substr(header, 2) > out
            for (i = 1; i <= nlines; i++) print seq[i] > out
            close(out)
            split(substr(header, 2), parts, /[ \t]+/)
            print isolate, id, parts[1], len, out > summary
        }
    }

    /^>/ { flush(); header = $0; len = 0; nlines = 0; next }
    NF   { gsub(/[ \t]/, ""); seq[++nlines] = $0; len += length($0) }

    END {
        flush()
        close(summary)
        printf "%s: %d plasmid contig(s) extracted (circular, %d <= length < %d bp)\n", \
            isolate, n, min_len, max_len > "/dev/stderr"
    }
'

#!/bin/sh

# force sorting to be byte-wise
export LC_ALL="C"

# cURL setup
#
# use compression
# - DISABLE if you encounter unsupported encoding algorithm
# follow redirects
# don't use keepalive 
# - there's not reason for it, we're closing the connection as soon
# - as we download the file
# try to guess the timestamp of the remote file
# retry 5 times with 30s delay in between
# fail silently instead of continuing
# don't print out anything (silent)
# add user-agent
# - some websites refuse the connection if the UA is cURL
alias curl='curl --compressed --location --no-keepalive --remote-time --retry 3 --retry-delay 30 --fail --silent --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"'

# force grep to work with text in order to avoid some files being treated as binaries
alias grep='grep --text'

# description / options for this script
HELP_TXT="$(basename "$0") [-h] [-o /<path>] [-t /<path>] [-b /<path>] [-w /<path>]

fetch and concatenate/clean a list of potentially unwanted domains

options:
    -h  show this help text
    -o  path for the output file
    -t  path to a directory, to be used as storage for temporary files
        default: /tmp
    -b  path to a list of domains to block
    -w  path to a list of domains to whitelist

This program requires: awk, coreutils, curl, grep, gzip, jq, python3 and sed to be installed and accessible."


# fetch and clean "ad_block" rules, some rules
# will be dropped as they are dependent on elements
# or URL parts.
# - <!!><domain><^>
fetch_ad_block_rules() {
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -o "$TARGET" -z "$TARGET" -k "$1"

        CONTENTS=$(
            # remove all comments
            grep -v -F '!' < "$TARGET" |\
            # remove all exceptions
            grep -v -F '@@' |\
            # remove url arg
            grep -v -F '?' |\
            # remove wildcard selectors
            grep -v -F '*' |\
            # match only the beginning of an address
            grep '||'
        )

        # save the contents to a temporary file
        echo "$CONTENTS" > "$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        shift
    done
}

# fetch and get the domains
# - /feed
fetch_ayashige_feed() {
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -H "accept: application/json" -o "$TARGET" -z "$TARGET" -k "$1"

        CONTENTS=$(
            # use jq to grab all domains
            jq -r '.[].domain' < "$TARGET"
        )

        # save the contents to a temporary file
        echo "$CONTENTS" > "$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        shift
    done
}

# fetch csv and extract fqdn
# - "<id>","<type>","<url>","<date>"
fetch_benkow_feed() {
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -o "$TARGET" -z "$TARGET" -k "$1"

        CONTENTS=$(
            # grab urls
            awk -F '";"' '{print $3}' < "$TARGET" |\
            # grab the domain from an entry with/without url scheme
            awk -F '/' '{ if ($0~"(http|https)://") {print $3} else {print $1} }'
        )

        # save the contents to a temporary file
        echo "$CONTENTS" > "$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        shift
    done
}

# fetch and clean domain lists with "#" comments, i.e.
# - <domain> #<comment>
# - #<comment>
fetch_domains_comments() {
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -o "$TARGET" -z "$TARGET" -k "$1"

        CONTENTS=$(
            # remove line comments and preserve the domains
            sed -e 's/#.*$//' -e '/^$/d' < "$TARGET" |\
            # remove all comments
            grep -v '#'
        )

        # save the contents to a temporary file
        echo "$CONTENTS" > "$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        shift
    done
}

# fetch json-encoded array of domains
# - [ "<domain>" ]
fetch_json_array_feed() {
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -H "accept: application/json" -o "$TARGET" -z "$TARGET" -k "$1"

        CONTENTS=$(
            # grab fqdn
            jq -r '.[]' < "$TARGET"
        )

        # save the contents to a temporary file
        echo "$CONTENTS" > "$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        shift
    done
}

# fetch and clean domain lists with a "hosts" file format
# - <ip><tab|space><domain>
fetch_hosts() {
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -o "$TARGET" -z "$TARGET" -k "$1"

        CONTENTS=$(
            # remove all comments
            grep -v '#' < "$TARGET" |\
            # remove all ipv4 addresses in format:
            # - 127.0.0.1<SPACE>
            sed -e 's/127.0.0.1\s//g' |\
            # remove all ipv4 addresses in format:
            # - 0.0.0.0<SPACE>
            sed -e 's/0.0.0.0\s//g' |\
            # remove all ipv6 addresses in format:
            # - ::<SPACE>
            sed -e 's/\:\:\s//g' |\
            # remove all ipv6 addresses in format:
            # - ::1<SPACE>
            sed -e 's/\:\:1\s//g'
        )

        # save the contents to a temporary file
        echo "$CONTENTS" > "$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        shift
    done
}

# fetch malsilo's feed
# - master-feed.json
fetch_malsilo_feed() {
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -o "$TARGET" -z "$TARGET" -k "$1"

        CONTENT_DROP_SITES=$(
            # grab urls
            jq -r '.data[] | .drop_sites[]' < "$TARGET" |\
            # grab the domain from an entry with/without url scheme
            awk -F '/' '{ if ($0~"(http|https)://") {print $3} else {print $1} }'
        )

        CONTENT_DNS_REQUESTS=$(
            # grab urls
            jq -r '.data[].network_traffic | select(.dns != null) | .dns[]' < "$TARGET"
        )

        TEMP_FILE="$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        # save the contents to a temporary file
        echo "$CONTENT_DROP_SITES" > "$TEMP_FILE"
        echo "$CONTENT_DNS_REQUESTS" >> "$TEMP_FILE"

        shift
    done
}

# fetch PhishStats's PhishScore CSV
# - "<date>","<score>","<url>","<host>"
fetch_phishstats_feed() {
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -o "$TARGET" -z "$TARGET" -k "$1"

        CONTENTS=$(
            # grab the domains only
            awk -F '","' '{print $3}' < "$TARGET" |\
            # grab the domain from an entry with/without url scheme
            awk -F '/' '{ if ($0~"(http|https)://") {print $3} else {print $1} }'
        )

        # save the contents to a temporary file
        echo "$CONTENTS" > "$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        shift
    done
}

# fetch gzipped Phishtank feed
# - verified_online.csv.gz
fetch_phishtank_gz() {
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -o "$TARGET" -z "$TARGET" -k "$1"
        
        CONTENTS=$(
            # inflate
            gzip -c -d "$TARGET" |\
            # grab the urls
            awk -F ',' '{print $2}' |\
            # grab the domain from an entry with/without url scheme
            awk -F '/' '{ if ($0~"(http|https)://") {print $3} else {print $1} }' |\
            # strip malformed urls
            sed -e 's/\?.*$//g'
        )

        # save the contents to a temporary file
        echo "$CONTENTS" > "$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        shift
    done
}

# fetch and extract domains from a list with urls
# <http|https://>
# note: URL lists are more prone to false-positives
fetch_url_hosts(){
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -o "$TARGET" -z "$TARGET" -k "$1"

        CONTENTS=$(
            # remove all comments
            sed '/^#/ d' < "$TARGET"  |\
            # grab the domain from an entry with/without url scheme
            awk -F '/' '{ if ($0~"(http|https)://") {print $3} else {print $1} }'
        )

        # save the contents to a temporary file
        echo "$CONTENTS" > "$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        shift
    done
}


# fetch csv and extract fqdn
# - "<id>","<type>","<url>","<date>"
fetch_viriback_feed() {
    while test $# -gt 0
    do
        TARGET=$(readlink -m "$TEMP_DIR/sources/$(echo "$1" | md5sum - | cut -c 1-32)")

        echo " -- $TARGET - $1"

        curl -o "$TARGET" -z "$TARGET" -k "$1"

        CONTENTS=$(
            # grab urls
            awk -F ';' '{print $2}' < "$TARGET" |\
            # grab the domain from an entry with/without url scheme
            awk -F '/' '{ if ($0~"(http|https)://") {print $3} else {print $1} }'
        )

        # save the contents to a temporary file
        echo "$CONTENTS" > "$TEMP_DIR/$(($(date +%s%N)/1000000)).temporary"

        shift
    done
}

python_idna_encoder() {
    python3 -c "
import sys;

for line in sys.stdin:
    try:
        print(line.strip().encode('idna').decode('ascii'))
    except:
        pass
"
}

# clean up/format the domain list for final version
sanitize_domain_list() {
    cat "$TEMP_DIR"/*.temporary |\
    # lowercase everything
    awk '{print tolower($0)}' |\
    # remove malformed url args
    awk -F '?' '{print $1}' |\
    # remove "dirty" urls
    awk -F '/' '{print $1}' |\
    # remove port left-overs
    awk -F ':' '{print $1}' |\
    # remove the start match and separator symbols
    sed -e 's/||//g' -e 's/\^//g' |\
    # remove single/double quotes (artifacts from parsing)
    sed -e "s/'/ /g" -e 's/\"//g' |\
    # remove ips
    grep -v '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$' |\
    # remove invalid domain names
    grep '\.' |\
    # filter out IDNA non-conforming domains
    python_idna_encoder |\
    # sort (and remove duplicates) entries
    sort -u |\
    # remove all white-listed domains
    grep -Evxf "$WHITELIST"
}

# remove the left-over temporary files
clean_temporary_files() {
    # remove the temporary files
    rm -rf "$TEMP_DIR"/*.temporary
}

# helper - warn if something is missing
verify_dependencies() {
    while test $# -gt 0
    do
        if ! command -v "$1" >/dev/null 2>&1; then
            echo "Missing dependency: $1"
            echo ""
            echo "You can run this program with -h, to see the list of software dependencies."
            exit 1
        fi
        shift
    done
}

while getopts "ho:b:t:w:" opt; do
  case $opt in
    b)  BLOCKLIST="$OPTARG"
        ;;
    h)  echo "$HELP_TXT"
        exit 1
        ;;
    o)  OUT_FILE="$OPTARG"
        ;;
    t)  TEMP_DIR="$OPTARG"
        ;;
    w)  WHITELIST="$OPTARG"
        ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
        ;;
  esac
done

verify_dependencies "awk" "cat" "curl" "cut" "date" "grep" "gzip" "jq" "md5sum" "mkdir" "python3" "readlink" "sed" "sort" "rm"

if [ -z "$OUT_FILE" ]; then
    echo 'Invalid output file path.'
    exit 1
fi

if [ -z "$TEMP_DIR" ]; then
    TEMP_DIR="/tmp"
fi

if [ "$BLOCKLIST" ]; then
    cp "$BLOCKLIST" "$TEMP_DIR/blocklist.temporary"
fi

if [ -z "$WHITELIST" ]; then
    WHITELIST="/dev/null"
fi

mkdir -p "$TEMP_DIR/sources"

echo "[*] updating domain list..."
fetch_domains_comments \
    "https://raw.githubusercontent.com/t0ny54/adultfilter/main/blocklist.txt"

sanitize_domain_list > "$OUT_FILE"

clean_temporary_files

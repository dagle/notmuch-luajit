#!/bin/bash

## setup test data
TEST_ROOT=$(dirname "$0")
TEST_ROOT=$(realpath ${TEST_ROOT})
echo $TEST_ROOT
TMP_DIRECTORY="${TEST_ROOT}/testdir"


if [[ ! -d "$TMP_DIRECTORY" ]]; then
mkdir ${TMP_DIRECTORY}
MAIL_DIR="${TMP_DIRECTORY}/testdata"

if [[ ! -d "$MAIL_DIR" ]]; then
	git clone https://github.com/dagle/galore-test $MAIL_DIR
fi

# setup notmuch
NOTMUCHDIR="${TMP_DIRECTORY}/notmuch/"
mkdir ${NOTMUCHDIR}
export NOTMUCH_CONFIG="${NOTMUCHDIR}/notmuch-config"

cat <<EOF >"${NOTMUCH_CONFIG}"
[database]
path=${MAIL_DIR}/testmail
hook_dir=${NOTMUCHDIR}

[user]
name=Testi McTest
primary_email=testi@testmail.org
other_email=test_suite_other@testmailtwo.org;test_suite@otherdomain.org
EOF

# init
notmuch new
fi

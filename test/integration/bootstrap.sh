#!/bin/sh

tmpdir=${TMPDIR:-/tmp}

test ! -e $tmpdir/folder && \
  mkdir $tmpdir/folder
chmod 0567 $tmpdir/folder

echo -n 'hello world' > $tmpdir/file
test ! -e $tmpdir/symlink && \
  ln -s $tmpdir/file /tmp/symlink
chmod 0777 $tmpdir/symlink
chmod 0765 $tmpdir/file

echo -n 'hello suid/sgid/sticky' > $tmpdir/sfile
chmod 7765 $tmpdir/sfile

echo -n 'hello space' > $tmpdir/spaced\ file

test ! -e $tmpdir/pipe && \
  mkfifo $tmpdir/pipe

test ! -e $tmpdir/block_device && \
  mknod $tmpdir/block_device b 7 7
chmod 0666 $tmpdir/block_device

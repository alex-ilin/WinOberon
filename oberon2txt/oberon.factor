! Copyright (C) 2016 Alexander Ilin.
USING: kernel sequences splitting math namespaces strings combinators
    io io.files io.binary io.encodings.binary io.encodings.utf8
    command-line ;
IN: oberon

! The implementation is based on text loading in Texts.Open of WinOberon.
! TextBlock = TextBlockId type hlen run {run} 0 tlen {AsciiCode} [font block].

ERROR: bad-format ;

CONSTANT: doc-id 247 ! F7 in hex
CONSTANT: metainfo-id1 247 ! F7 in hex
CONSTANT: metainfo-id2 8
CONSTANT: textblock-id1 1
CONSTANT: textblock-id2 240 ! F0 in hex

: skip-string ( -- )
    "\0" read-until 0 = [ bad-format ] unless drop ;

: read-int32 ( -- int32 )
    4 read le> ;

: skip-metainfo ( -- )
    read-int32 read drop ;

: skip-text-header ( first-byte -- text-length )
    dup textblock-id1 = swap textblock-id2 = or [ bad-format ] unless
    read1 drop
    read-int32 10 - read drop
    read-int32 ;

: (skip-doc-header) ( -- next-byte )
    read1 drop
    skip-string 4 2 * read drop
    read1
    dup metainfo-id1 = [
        drop read1 dup metainfo-id2 = [
            drop skip-metainfo read1
        ] when
    ] when ;

: skip-doc-header ( first-byte -- next-byte )
    dup doc-id = [ drop (skip-doc-header) ] when ;

: filter-text ( text-length -- string )
    read
    { CHAR: \r } { CHAR: \n } replace
    [
        {
            { CHAR: \t [ t ] }
            { CHAR: \n [ t ] }
            [ CHAR: space >= ]
        } case
    ] filter >string ;

: read-contents ( -- string )
    read1 skip-doc-header skip-text-header filter-text ;

: oberon>ascii ( -- )
    command-line get first
    binary [ read-contents ] with-file-reader
    "d:/Programs/Dev/git/cmd/temp" utf8 [ write ] with-file-writer ;

! Note: replace the last line with "write ;" to write to stdout.
! Unfortunately, that didn't work with Git for Windows, so a temp-file was used as a workaround.

: convert-file ( out-file in-file -- )
    binary [ read-contents ] with-file-reader
    swap utf8 [ write ] with-file-writer ;

MAIN: oberon>ascii

bluemonday-cli
==============

bluemonday-cli is a simple command-line interface to
[bluemonday](https://github.com/microcosm-cc/bluemonday).

We've configured bluemonday for ROVR's specific requirements. It reads
input from [Quill](https://github.com/quilljs/quill/). You should read
the code and adjust to your app's needs!

Installation
------------

    go get github.com/rovrlabs/bluemonday-cli

Will install as $GOPATH/bin/bluemonday-cli

Usage
-----

`echo '<script>scary html</script>' | bluemonday-cli`

License
-------

bluemonday-cli is copyright (c) 2021-2022 ROVR LABS INC. and is
distributed under the ISC license. See LICENSE for details.

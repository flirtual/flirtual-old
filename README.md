Flirtual
========

The VR dating app.

Dependencies
------------

Everything needed for the main application server is included in
vendor/. You just need C and Golang (>=1.11) compilers to build. It is
highly recommended to build statically for maximum performance
(including any external programs you run from kwerc). musl is ideal
(though may create bugs in 9base in some environments).

A simple `make` will compile the vendor dependencies and put them in the
right place. You don't need to run `make install` (in fact, you can't)
-- everything is self-contained in the kwerc directory.

Debian:
```
# apt install build-essential golang-go
$ make
```

Alpine:
```
# apk add build-base go
$ make
```

To run the full application, you will also need a Redis server with the
RedisGraph module, an ejabberd server with
[some configuration](https://github.com/rovrlabs/rovr-ejabberd),
[flirtual-cron](https://github.com/rovrlabs/flirtual-cron), and
[flirtual-static](https://github.com/rovrlabs/flirtual-static) (which we
host in object storage but can also just be thrown into app/sites/).

Usage
-----

`./bin/cgd -c app/es/kwerc.es`

Flirtual should now be reachable at http://127.0.0.1:42069.

Contributing
------------

Contributions are more than welcome. Feel free to take an issue or open
a new one.

Development discussion happens on [Discord](https://flirtu.al/discord)
(Flirtual -> #developers channel).

Contact
-------

hello@flirtu.al

License
-------

Flirtual is copyright (c) 2018-2022 ROVR LABS INC. and is distributed under
the AGPLv3 license. See LICENSE for details.

Dependencies under vendor/ have their own licenses. Read them.

See also
--------

Flirtual is built with the [kwerc](https://kwerc.org) web framework. Its
documentation might be helpful. And contributions are welcome there too!

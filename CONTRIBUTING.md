# Contribution Guide

All development is done against [Neovim][neovim]. The plugin itself
doesn't make use of any Neovim-specific features, but the tests use
Neovim's msgpack-rpc interface.

The tests require Python 3.4+, [Neovim's Python client][neovim-python],
and [neovim-unittest][neovim-unittest]. You can run the tests from the
project root:

```
$ python -m unittest
```

Try to to follow the [Earl Grey contribution
guidelines][earlgrey-contrib] regarding highlighting and editor support.


[earlgrey-contrib]: https://breuleux.github.io/earl-grey/contrib.html
[neovim]: https://neovim.io/
[neovim-python]: https://github.com/neovim/python-client
[neovim-unittest]: https://github.com/tomxtobin/neovim-unittest

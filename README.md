navi
=====
navi(NixOS Advanced Virtual Infrastructure) is a set of NixOS configuration
files handling my own internal infrastructure.

Currently the machines populated by this configuration are:

* alastor
* xanadu

WARNING: This is a very heavily WIP project and has an uncommon threat model, as
such you might want to really document yourself before using parts of this
software! Please read `docs/README.txt` at the very least!


## Development Notes

Do not forget to run `pre-commit install` to get the formatting hooks running
before contributing!

For security reasons, you will want to set git pull path to https and git push
patch to ssh, obviously this is only useful if you actually develop navi.

To do that run the following commands, using my own repository as an example:
```sh
git remote set-url origin https://code.govanify.com/govanify/navi.git
git remote set-url origin --push git@code.govanify.com:govanify/navi.git
```

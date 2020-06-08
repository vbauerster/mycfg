### [Dotfiles bootstrap](https://postimg.cc/WDXn3bsC)

```sh
export tmpdir=$(mktemp -d)
git clone --depth=1 --separate-git-dir=$HOME/.myconf https://github.com/vbauerster/myconf $tmpdir
alias c='git --git-dir=$HOME/.myconf --work-tree=$HOME'
c config status.showUntrackedFiles no
c config tig.status-show-untracked-files false
c reset --hard
c submodule update --init --recursive
rm -fr $tmpdir
```

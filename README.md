# [`home`](https://github.com/sempernow/home "GitHub/sempernow/home") 

All The Things for a happy `~` in any box.

- Linux
    - `bash`
    - `sh`
- WSL(2)
- Windows Git bash
- Cygwin

## The Things

See the files. Run the recipes. Menu: `make`

[Git completion scripts](https://github.com/git/git/tree/master/contrib/completion "github.com/git")

## Install

For `$USER`

```bash
git clone https://github.com/sempernow/home.git
cd home
make user
```

For all users

```bash
git clone https://github.com/sempernow/home.git
cd home
make all
```

## Demo 

Open new shell, or from current shell (after install) &hellip; 

```bash
# Regular user
bash
# Login shell
bash --login
# Root user
sudo su -
```

## Demo at `bash` and `sh` Environments

### `sh` @ busybox (or alpine)

```bash
app=bbox
docker run --rm -d --name $app -v $(pwd):/root -w /root busybox sleep 1d
``` 

```bash
docker exec -it $app sh
```
```bash
~ # . ./.bashrc
```

### `bash` @ Ubuntu

```bash
app=ubox
docker run --rm -d --name $app -v $(pwd):/root -w /root ubuntu sleep 1d
```

```bash
docker exec -it $app bash
```
- Fails @ `sh`

Useful:

```bash
# Create a user
adduser u1
# Allow multi-byte Unicode character prompt
export LANG=${LANG:-C.UTF-8}
```


### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](file:///d:/1%20Data/IT/___.html "@ browser") | [MD](file:///d:/1%20Data/IT/___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->


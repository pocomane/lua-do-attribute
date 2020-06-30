
SCRDIR=$( dirname $( readlink -f "$0" ))
SCRPATH="$SCRDIR/$( basename "$0" )"
PKGDIR="$SCRDIR/pkg"

############

mkdir -p "$PKGDIR"
curl https://www.lua.org/ftp/lua-1.0.tar.gz >   "$PKGDIR/lua-1.0.tar.gz"
curl https://www.lua.org/ftp/lua-1.1.tar.gz >   "$PKGDIR/lua-1.1.tar.gz"
curl https://www.lua.org/ftp/lua-2.1.tar.gz >   "$PKGDIR/lua-2.1.tar.gz"
curl https://www.lua.org/ftp/lua-2.2.tar.gz >   "$PKGDIR/lua-2.2.tar.gz"
curl https://www.lua.org/ftp/lua-2.4.tar.gz >   "$PKGDIR/lua-2.4.tar.gz"
curl https://www.lua.org/ftp/lua-2.5.tar.gz >   "$PKGDIR/lua-2.5.tar.gz"
curl https://www.lua.org/ftp/lua-3.0.tar.gz >   "$PKGDIR/lua-3.0.tar.gz"
curl https://www.lua.org/ftp/lua-3.1.tar.gz >   "$PKGDIR/lua-3.1.tar.gz"
curl https://www.lua.org/ftp/lua-3.2.2.tar.gz > "$PKGDIR/lua-3.2.2.tar.gz"
curl https://www.lua.org/ftp/lua-4.0.1.tar.gz > "$PKGDIR/lua-4.0.1.tar.gz"
curl https://www.lua.org/ftp/lua-5.0.3.tar.gz > "$PKGDIR/lua-5.0.3.tar.gz"
curl https://www.lua.org/ftp/lua-5.1.5.tar.gz > "$PKGDIR/lua-5.1.5.tar.gz"
curl https://www.lua.org/ftp/lua-5.2.4.tar.gz > "$PKGDIR/lua-5.2.4.tar.gz"
curl https://www.lua.org/ftp/lua-5.3.5.tar.gz > "$PKGDIR/lua-5.3.5.tar.gz"
curl https://www.lua.org/ftp/lua-5.4.0.tar.gz > "$PKGDIR/lua-5.4.0.tar.gz"

############

rm -fR git_lua_rel
mkdir -p git_lua_rel || exit -1
cd git_lua_rel || exit -1
git init || exit -1
git commit --allow-empty -m "repo init" || exit -1

git branch patch || exit -1
git checkout patch || exit -1

mkdir script || exit -1
cp "$SCRPATH" script || exit -1
git add script/* || exit -1
git commit -m "PATCH branch." || exit -1

git branch upstream || exit -1
git checkout upstream || exit -1

############

extract(){
  mv script .script || exit -1
  rm -fR *
  tar -xzf "$PKGDIR/lua-$VER.tar.gz" || exit -1
  mv lua*/* ./ || exit -1
  rmdir lua* || exit -1
  mv .script script || exit -1
}

VER="1.1"
extract
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="2.1"
extract
#
git rm Makefile
#
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="2.2"
extract
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="2.4"
extract
#
git rm domake
#
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="2.5"
extract
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="3.0"
extract
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="3.1"
extract
#
git rm -r clients
#
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="3.2.2"
extract
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="4.0.1"
extract
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="5.0.3"
extract
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="5.1.5"
extract
#
git rm DIFFS MANIFEST UPDATE build config configure
git rm -r include
#
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="5.2.4"
extract
#
git rm COPYRIGHT HISTORY INSTALL
git rm -r test etc
#
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="5.3.5"
extract
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

VER="5.4.0"
extract
git add * || exit -1
git status || exit -1
git commit -m "Lua $VER" || exit -1

###

git checkout patch || exit -1
git merge upstream


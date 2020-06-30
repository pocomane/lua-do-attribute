
# Lua do-attibute

This is a patched version of Lua 5.4.0. The original lua README was moved in
doc/README: please refer to it for build instructions.

The patch lets you to mark a do/end block in this way:
`do <attrib> --[[block-content]]  end`

The accepted attibutes are:

- `<defer>` - the block is executed at end of the current scope instead of
immediately
- `<withupvalue>` - a free name inside this block raises an error instead
of being translated to `__ENV.name`
- <`localonly>` - an error is raised when accessing an upvalue too (so
local variables only are allowed)
- `<autoglobal> `- it overwrites `<withupvalue>` or `<localonly>` to make the block
work again like the common do/end block

The command

> ./script/doattr_test.sh

will download the official lua test suite, it will add some do attribute tests,
and it will run them all.

NOTE:
The body of a `<defer>` block works like the body of a function set as `__close`
metatamethod of a `<close>` variable (i.e. the return statements are executed
outside the current thread).

NOTE:
`<defer>` uses a new global function "defer" to work. It is equivalent to
`local _--[[var-name]] <close> = defer(function() --[[block-content]] end)`.
The user can change its behaviour by re-defining `defer`.

NOTE:
`<autoglobal>`, `<wihtupvalue>` and `<localonly>` logic:
- A non-marked do/end block inherits the behaviour from the parent block.
- The main chunk starts in the `<autoglobal>` mode (as usual).

NOTE:
`<autoglobal>`, `<wihtupvalue>` and `<localonly>` rises error at compile time, so the
performance should not be affected.

NOTE:
`<autoglobal>`, `<wihtupvalue>` and `<localonly>` are somehow "Compatible" with the
regular lua: if you write a script that works as expected with the patch, you
can remove any mark from the do/end blocks, and the result is valid for the
regular lua too.

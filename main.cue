package main

import (
    "dagger.io/dagger"

    "github.com/sun-yryr/agqr-program-guide/ci"
)

dagger.#Plan & {
    // Say hello by writing to a file
    actions: hello: ci.#AddHello & {
        dir: client.filesystem.".".read.contents
    }
    client: filesystem: ".": {
        read: contents: dagger.#FS
        write: contents: actions.hello.result
    }
}

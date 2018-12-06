# Feihong's Racket Quickstart

## Prerequisites

1. Download [.dmg file](https://racket-lang.org/download/) and install
1. Open `/Applications/Racket v7.1` and open `DrRacket`
1. Select Language > Choose Language... > The Racket Language
1. Run these commands:
      ```bash     
      ln -s /Applications/Racket\ v7.1/bin/racket /usr/local/bin/racket
      ln -s /Applications/Racket\ v7.1/bin/raco /usr/local/bin/raco
      ```

### Generate project

    raco pkg new <name-of-project>

Add your dependencies to `info.rkt`.

Install dependencies

    raco pkg install --deps

## Common commands

Start interpreter

    racket

Execute program

    racket src/hello.rkt

# c9-plus
A Dockerfile about c9, integrating tools I need

## Note:

The tools I choose are just what I need, so it will change frequently piece by piece. Because I am located at China, so I will try to change to related mirrors close to China.

For now what I need to integrated are as below:

- Useful apt packages
- Cloud9
- PHP & related extensions ( try to use to the newest version)
- Composer
- Drush ( a cli tools for Drupal Projects )
- Drupal Console ( another Drupal cli tools )
- Laravel Installer ( a cli tools for Laravel Projects )
- Node (nvm, nrm, latest version node and npm)
- common used node command line tools

## Features

- As I tested, c9 works with php and xdebug, it's cool!
- As a web developer, I plan to integrate all tools I love to use.

## Usage

```
docker run --rm -p 8080:80 -v "$PWD:/workspace/" vipzhicheng/c9-plus
```

PS: I always make an alias to ~/.bashrc

```
alias edit='alias edit='docker ps -a -q -f name=^/c9$ | xargs docker stop || true && docker run --rm --name c9 -p 3000:3000 -p 8888:80 -p 8080:8080 -p 8000:8000 -v "$PWD:/workspace/" vipzhicheng/c9-plus'
```
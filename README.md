# c9-plus
A Docker file about c9, integrating tools I need

## Note:

The tools I choose are just what I need, so it will change frequently piece by piece. Because I am located at China, so I will try to change to related mirrors close to China.

For now what I need to integrated are as below:

- Useful cli softwares
- Cloud9
- PHP & related repos ( try to use to the newest version)
- Composer
- Drush ( a cli tools for Drupal Projects )
- Drupal Console ( another Drupal cli tools )
- Laravel Installer ( a cli tools for Laravel Projects )
- NPM taobao mirror

## Usage

```
docker run --rm -p 8080:80 -v "$PWD:/workspace/" vipzhicheng/c9-plus
```

PS: I always make an alias to ~/.bashrc

```
alias edit='docker run --rm -p 8080:80 -v "$PWD:/workspace/" vipzhicheng/c9-plus'
```
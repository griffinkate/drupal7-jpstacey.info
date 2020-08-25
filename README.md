# Drupal 7 codebase for jpstacey.info

Prior to export to a static site, this codebase powered www.jpstacey.info. It's no longer in service nor actively maintained.

It can still be run (at the time of writing) locally by using the following:

## Installation

### Requirements

- PHP (anything from 5.5 to 7.0).
- Some kind of web server (eg: Apache)
- Some kind of db server (eg: MariaDB)
- **NB: A database with content: available on request.**

## Recommended approach

- Get Lando: https://lando.dev/download/
- Get Docker: https://docs.docker.com/get-docker/

```
git checkout <repo path>
lando start
lando db-import path-to-db.sql.gz
<adjust settings.php as needed>
```

## Comments

Please use the repository Issues to raise any questions or comments.

# License

Unless stated otherwise, the codebase is released under the [MIT License](http://www.opensource.org/licenses/mit-license.php).

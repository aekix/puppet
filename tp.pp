package {
'apache2':
  ensure   => present,
}

package {
'php7.3':
  ensure   => present,
  name     => 'php7.3',
  provider => apt
}

file {
'download':
  ensure => present,
  path   => '/usr/src/dokuwiki.tgz',
  source => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz'
}

exec {
'unzip':
  command => 'tar xavf dokuwiki.tgz',
  cwd     => '/usr/src',
  path    => ['/usr/bin'],
  require => File['download']
}

file {
'rename':
  ensure  => present,
  source  => '/usr/src/dokuwiki-2020-07-29',
  path    => '/usr/src/dokuwiki',
  require => File['unzip']
}

file {
'rights recettes':
  encure  => directory,
  path    => '/var/www/recettes.wiki',
  recurse => true,
  owner   => 'www-data',
  group   => 'www-data'
}

file {
'rights politique':
  encuse  => directory,
  path    => '/var/www/politique.wiki',
  recurse => true,
  owner   => 'www-data',
  group   => 'www-data'
}

file {
'Cp recettes.wiki':
  ensure  => present,
  source  => '/usr/src/dokuwiki',
  path    => '/var/www/recettes.wiki',
  require => [File['rights recettes'], File['rename']]
}

file {
'Cp politique.wiki':
  ensure  => present,
  source  => '/usr/src/dokuwiki',
  path    => '/var/www/politique.wiki',
  require => [File['rights politique'], File['rename']]
}

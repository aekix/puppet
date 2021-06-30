class dokuwiki {
  include dokuwiki::params
  include dokuwiki::packages
  include dokuwiki::source
}

class dokuwiki::packages {
  package { 'apache2':
    ensure => present
  }

  package { 'php7.3':
    ensure => present
  }
}

# 3 

class dokuwiki::source {
  include dokuwiki::params

  file { 'dokuwiki::download':
    ensure => present,
    source => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
    path   => "${source_path}/dokuwiki.tgz"
  }

  # 4 

  exec { 'dokuwiki::extract':
    command => 'tar xavf dokuwiki.tgz',
    cwd     => "${source_path}",
    path    => ["${binary_path}"],
    require => File['dokuwiki::download'],
    unless  => "test -d ${source_path}/dokuwiki-2020-07-29"
  }

  file { 'dokuwiki::rename':
    ensure  => present,
    source  => "${source_path}/dokuwiki-2020-07-29",
    path    => "${source_path}/dokuwiki",
    require => Exec['dokuwiki::extract']
  }
}

class dokuwiki::params {
  $source_path = '/usr/src'
  $web_path = '/var/www'
  $binary_path = '/usr/bin'
}

define dokuwiki::deploy ($env="", $documentroot) {
  include dokuwiki::params

  file { "$env":
    ensure  => directory,
    source  => "${source_path}/dokuwiki",
    path    => "${web_path}/${env}",
    recurse => true,
    owner   => 'www-data',
    group   => 'www-data',
    require => File['dokuwiki::rename']
  }
  file {
    "host":
      ensure  => file,
      path    => "/etc/apache2/sites-enabled/${env}.conf",
      content => template('/vagrant/vhost.conf')
    }
}

node 'server0' {
  include dokuwiki
  include dokuwiki::params
  
  dokuwiki::deploy { "recettes.wiki":
    env => "recettes.wiki",
    documentroot => "${web_path}/recettes.wiki"
	
  }
  dokuwiki::deploy { "tajineworld.com":
    env => "tajineworld.com",
    documentroot => "${web_path}/tajineworld.com"
  }
}

node 'server1' {
  include dokuwiki

  dokuwiki::deploy { "politique.wiki":
    env => "politique.wiki",
    documentroot => "${web_path}/politique.wiki"
  }
}

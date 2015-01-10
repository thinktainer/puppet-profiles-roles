class profiles::yumrepo (
  $repopath = '/repo'
) {

  package { 'createrepo':
    ensure => installed
  }

  file { 'repo':
    path   => $repopath,
    ensure => directory,
  }

  package { 'httpd':
    ensure => installed
  }

  file { 'http-link':
    path   => '/var/www/html/repo',
    ensure => link,
    target => $repopath,
  }

  exec { 'run-createrepo':
    command => "createrepo ${repopath}",
    path    => "/usr/bin:/usr/sbin",
    creates => "${repopath}/metadata/repomd.xml"
  }

  class { 'selinux':
    mode => 'permissive' }

  service { 'httpd':
    ensure => running
  }

  Package['createrepo'] ->
  File['repo'] ->
  Package['httpd'] ->
  File['http-link'] ->
  Exec['run-createrepo'] ->
  Class['selinux'] ->
  Service['httpd'] 

}

class profiles::puppetmaster (
  $package_name = 'puppetmaster',
  $service_name = 'puppetmaster',
  $puppetmaster_hostnames = 
    'puppetmaster.ms.devnet,puppetmaster,puppet.ms.devnet,puppet',
  $r10k_remote = 'git@github.com:bedegaming/puppet.git'

) {

  package {'puppetmaster':
    name   => $package_name,
    ensure => installed
  }

  class profiles::puppetmaster::configfiles (
    $puppet_conf_file_template = 'profiles/puppet.conf.erb',
    $hiera_yaml_file_template = 'profiles/hiera.yaml.erb',
    $autosign_net_file_template = 'profiles/autosign.conf.erb'
  ) {
    file {
      'puppetconf':
        path    => '/etc/puppet/puppet.conf',
        content => template($puppet_conf_file_template);
      'hierayaml':
        path    => '/etc/hiera.yaml',
        content => template($hiera_yaml_file_template);
      'autosign':
        path    => '/etc/puppet/autosign.conf',
        content => template($autosign_net_file_template)
    }
  }

  include profiles::puppetmaster::configfiles

  Package[$package_name] ->
  File <| tag == 'profiles::puppetmaster::configfiles' |> {
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
    }   -> File['hiera_symlink']
        ~> Service['puppetmaster']


    file { 'hiera_symlink':
      ensure => symlink,
      path   => '/etc/puppet/hiera.yaml',
      target => '/etc/hiera.yaml'
    }

    service {'puppetmaster':
      name        => $service_name,
      ensure      => running,
      enable      => true,
      hasrestart  => true,
      hasstatus   => true
    }

    class { 'r10k':
      sources => {
        'puppet' => {
          basedir => "${::settings::confdir}/environments",
          remote => $profiles::puppetmaster::r10k_remote,
          prefix => false
        }
      }
    }

}


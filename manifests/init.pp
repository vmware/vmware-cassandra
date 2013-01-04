# Class: cassandra
#
# This class installs Apache Cassandra
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class cassandra (
  $version        = $cassandra::params::version,
  $cassandra_home = $cassandra::params::cassandra_home,
  $source_file    = $cassandra::params::source_file,
  $source         = $cassandra::params::source
) inherits cassandra::params{

  include '::java'
  include 'staging'

  staging::deploy { $source_file:
    target  => '/opt',
    creates => "/opt/apache-cassandra-${version}",
    source  => "${source}/${source_file}",
  }

  file { $cassandra_home:
    ensure  => link,
    target  => "/opt/apache-cassandra-${version}",
    require => Staging::Extract[$source_file],
  }

  file { [
    '/var/lib/cassandra',
    '/var/lib/cassandra/data',
    '/var/lib/cassandra/commitlog',
    '/var/lib/cassandra/saved_caches',
    '/var/log/cassandra'
  ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => File[$cassandra_home]
  }

  file { '/usr/local/bin/cassandra-cli':
    ensure  => link,
    target  => "${cassandra_home}/bin/cassandra-cli",
    require => File[$cassandra_home]
  }

  file { '/etc/init.d/cassandra':
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('cassandra/cassandra_init.erb'),
    require => File[$cassandra_home]
  }

  class { 'cassandra::service':
    ensure    => running,
    require   => [
      Class['java'],
      File['/etc/init.d/cassandra'],
    ]
  }

}

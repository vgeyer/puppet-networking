  # Class: networking
#
# Due restrictions of puppet as structural language it not possible to do this as type.
# The interfaces hash is currently not validated, so take care ;-)
#
# Example:
#  class{ 'networking':
#    interfaces => {
#      'wan0' => {
#        mac   => '52:51:00:f5:6a:41',
#        auto  => true,
#        inet => {
#          method => 'static',
#          family_settings => {
#            address     => '144.76.133.212',
#            broadcast   => '144.76.133.215',
#            netmask     => '255.255.255.224',
#            gateway     => '144.76.42.151',
#            pointopoint => '144.76.42.151'
#          },
#        },
#        inet6 => {
#          method => 'static',
#          family_settings => {
#            address     => '2a01:4f8:191:439a::a00b',
#            netmask     => '64',
#            gateway     => 'fe80::1'
#          }
#        }
#      }
#    }
#  }

class networking (
  $inet6_loopback = false,
  $interfaces = undef
) {
  # Because renaming the interfaces in interfaces before shutting down them causes
  # a RTNETLINK error we...
  Package['ifrename'] -> File['/etc/iftab.gen'] -> File['/etc/network/interfaces.gen'] ~> Exec['network_stop'] ~> Exec['create_net_links'] ~> Exec['ifrename'] ~> Exec['network_start']

  package { 'ifrename':
    ensure => installed
  }

  exec { 'network_stop':
    command     => '/etc/init.d/networking stop',
    refreshonly => true,
    user        => 'root'
  }
  # sadly we cannot notify a file to refresh so we gotta do this this way...
  exec { 'create_net_links':
    command     => '/bin/cp /etc/iftab.gen /etc/iftab && /bin/cp /etc/network/interfaces.gen /etc/network/interfaces',
    refreshonly => true,
    user        => 'root'
  }
  exec { 'ifrename':
    command     => '/sbin/ifrename',
    refreshonly => true,
    user        => 'root'
  }
  exec { 'network_start':
    command     => '/etc/init.d/networking start',
    refreshonly => true,
    user        => 'root',
  }

  file { '/etc/iftab.gen':
    ensure   => present,
    content  => template('networking/etc/iftab.erb'),
    mode     => '0644',
    owner    => 'root',
    group    => 'root'
  }
  file { '/etc/network/interfaces.gen':
    ensure  => present,
    content => template('networking/etc/network/interfaces.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',

  }
}
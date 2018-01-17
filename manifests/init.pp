# Installs the Ubiquiti UniFi network controller software.
class unifi_controller (
  $app_version    = '5.6.29',
  $app_https_port = '8443',
  ) {

  Exec {
    path => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
  }


  # Ubiquiti's packaging is a bit of a PITA, they package their software as debs
  # without APT repos and have a single package for all versions of Debian/
  # Ubuntu.

  $download_url = "http://dl.ubnt.com/unifi/${app_version}/unifi_sysvinit_all.deb"


  # Download and install the software.
  # TODO: Non-portable - Debian/Ubuntu Specific.
  exec { 'unifi_controller_download':
    creates   => "/tmp/unifi-controller-${app_version}.deb",
    command   => "wget -nv ${download_url} -O /tmp/unifi-controller-${app_version}.deb",
    unless    => "dpkg -s unifi-controller | grep -q \"Version: ${app_version}\"", # Download new version if not already installed.
    logoutput => true,
    notify    => Exec['unifi_controller_install'],
  }

  exec { 'unifi_controller_install':
    # Ideally we'd use "apt-get install package.deb" but this only become
    # available in apt 1.1 and later. Hence we do a bit of a hack, which is
    # to install the deb and then fix the deps with apt-get -y -f install.
    # TODO: When Ubuntu 16.04 is out, check if we can migrate to the better approach
    command     => "bash -c 'dpkg -i /tmp/unifi-controller-${app_version}.deb; apt-get -y -f install'",
    require     => Exec['unifi_controller_download'],
    logoutput   => true,
    refreshonly => true,
  }

  # Ensure the daemon is running and configured to launch at boot
  service { 'unifi':
    ensure    => 'running',
    enable    => true,
    require   => Exec['unifi_controller_install'],
  }


  # If the non-default port is requested, setup redirect using NAT rules and
  # the official puppetlabs firewall module. We have to do it this way, since
  # Unifi controller doesn't respect it's configuration file stating what port to
  # use. Note that firewalling will require you permit access to port 8443 due
  # to how prerouting works.

  if ($app_https_port != '8443') {

    # Annoyingly, we have to define both v4 and v6 - it's not automatic that
    # a single rule will create both. Hence, we specify the exact provider
    # of "iptables" vs "ip6tables", even though the config is otherwise identical

    firewall { '100 IPv4 port redirection for unifi controller':
      provider    => 'iptables',
      table       => 'nat',
      chain       => 'PREROUTING',
      proto       => 'tcp',
      dport       => '443',
      jump        => 'REDIRECT',
      toports     => '8443'
    }

    firewall { '100 IPv6 port redirection for unifi controller':
      provider    => 'ip6tables',
      table       => 'nat',
      chain       => 'PREROUTING',
      proto       => 'tcp',
      dport       => '443',
      jump        => 'REDIRECT',
      toports     => '8443'
    }
  }


}
# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:

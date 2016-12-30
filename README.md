# puppet-unifi_controller

## Overview

Provisions the Unifi Controller software provided by Ubiquiti for configuring
and managing their networking hardware.


## Configuration

Currently this module is limited to installed a specific version of the server:

    class { '::unifi_controller':
      app_version => '5.3.8', # pin specific version
    }

If left unset, `app_version` will be updated semi-frequently to the latest
version offered by Ubiquiti. If this isn't something you'd like, please pin
the version either using the syntax above, or by using Hiera.

This module does not configure any kind of firewall, it is *strongly*
recommended that you firewall this system heavily.

You may also wish to change the https port to be something more convenient
(eg `443`), if you change it from 8443, this module setups a firewall/NAT
redirect from 443 to 8443, since the port can't be changed using any built
in approach inside Unifi Controller itself. This requires the
[puppetlabs/firewall](https://forge.puppetlabs.com/puppetlabs/firewall) module.

Note, since this port change takes place in prerouting, you'll need to allow
access to TCP/8443 regardless of what you change the port to in your iptables
firewall rules.



## Requirements

The currently listed GNU/Linux platforms at the [Ubiquiti support page](https://www.ubnt.com/download/unifi)
are supported by this module.

There is no RHEL/clone version or any platforms other than x86_64 because
Ubiquiti don't provide any software/support for those platforms.


## Limitations

Ubiquiti don't make the software available as a proper APT repo, so we can't
(easily) do things like check for the latest version - so we currently pin to
specific versions.

The downloads of their package come direct from their website, if they change
their download methodology or packaging approach, this could break in future.



## Contributions

All contributions are welcome via Pull Requests including documentation fixes
or compatibility fixes for supporting other distributions (or other operating
systems).


## License

This module is licensed under the Apache License, Version 2.0 (the "License").
See the `LICENSE` or http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

===========
ddns-client
===========

Formula to install and configure a ddns (dynamic dns) client.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``ddns-client``
--------

Installs and configures a ddns script for use with common name servers, e.g. bind.

Example
=======

For bind:

1. Create a dnssec key

.. code::

  dnssec-keygen -a HMAC-MD5 -b 512 -n HOST name-of-key

2. Extract private key ('Key: ') from generated 'Ksomething.private'

.. code::

  > cat Ksomething.private
  Private-key-format: v1.3
  Algorithm: 157 (HMAC_MD5)
  Key: PRIVATE_KEY_HERE <-----
  Bits: AAA=
  Created: 20150224131204
  Publish: 20150224131204
  Activate: 20150224131204

3. Create /etc/bind/key.conf with content::

.. code::

  key keyname. {
      algorithm HMAC-MD5;
      secret "PRIVATE KEY";
  };

4. Edit /etc/bind/named.conf.local and include key file::

.. code::

  include "/etc/bind/keys.conf";

5. Edit named.conf.local and allow key for host update in desired zone::

.. code::

  zone "dyndns.my.tld" {
      type master;
      file "/var/cache/bind/db.dyndns.my.tld";
          
      update-policy{
          grant keyname. name home.dyndns.my.tld. ANY;
      };
  };

6. Reload bind::

.. code::

  rndc reload

7. Create pillar::

.. code::

  ddns_client:
    server: dns.my.tld
    zone: dyndns.my.tld
    hostname: home.dyndns.my.tld
    key: |
        key salt-dev. {
          algorithm HMAC-MD5;
          secret "PRIVATE KEY";
        };

See *ddns-client/pillar.example* for more details.

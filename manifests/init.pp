# == Class: mackerel_agent
#
# This class install and configure mackerel-agent
#
# === Parameters
#
# [*ensure*]
#   Passed to the mackerel_agent
#   Defaults to present
#
# [*apikey*]
#   Your mackerel API key
#   Defaults to undefined
#
# [*service_ensure*]
#   Whether you want to mackerel-agent daemon to start up
#   Defaults to running
#
# [*service_enable*]
#   Whether you want to mackerel-agent daemon to start up at boot
#   Defaults to true
#
# === Examples
#
#  class { 'mackerel_agent':
#    apikey => 'Your API Key'
#  }
#
# === Authors
#
# Tomohiro TAIRA <tomohiro.t@gmail.com>
#
# === Copyright
#
# Copyright 2014 - 2015 Tomohiro TAIRA
#
class mackerel_agent(
  $ensure              = present,
  $apikey              = undef,
  $service_ensure      = running,
  $service_enable      = true,
  $use_metrics_plugins = undef,
  $use_check_plugins   = undef,
  $metrics_plugins     = {},
  $check_plugins       = {},
) {
  validate_re($::osfamily, '^(RedHat|Debian)$', 'This module only works on RedHat or Debian based systems.')
  validate_string($apikey)
  validate_bool($service_enable)
  validate_hash($metrics_plugins)
  validate_hash($check_plugins)

  if $apikey == undef {
    crit('apikey must be specified in the class paramerter.')
  } else {
    class { 'mackerel_agent::install':
      ensure              => $ensure,
      use_metrics_plugins => $use_metrics_plugins,
      use_check_plugins   => $use_check_plugins
    }

    class { 'mackerel_agent::config':
      apikey          => $apikey,
      metrics_plugins => $metrics_plugins,
      check_plugins   => $check_plugins,
      require         => Class['mackerel_agent::install']
    }

    class { 'mackerel_agent::service':
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => Class['mackerel_agent::config']
    }
  }
}

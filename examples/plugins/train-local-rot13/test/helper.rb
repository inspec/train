# Test helper file for example Train plugins

# This file's job is to collect any libraries needed for testing, as well as provide
# any utilities to make testing a plugin easier.

# Load Train.  We certainly need the plugin system, and also several other parts
# that are tightly coupled.  Train itself is fairly light, and non-invasive.
require 'train'

# InSpec core provides a number of such libraries and facilities, in the file
# lib/pligins/shared/core_plugin_test_helper.rb . So, one job in this file is
# to locate and load that file.
# require 'inspec/../plugins/shared/core_plugin_test_helper'

# Caution: loading all of InSpec (ie require 'inspec') may cause interference with
# minitest/spec; one symptom would be appearring to have no tests.
# See https://github.com/inspec/inspec/issues/3380

# You can select from a number of test harnesses.  Since InSpec uses Spec-style controls
# in profile code, you will probably want to use something like minitest/spec, which provides
# Spec-style tests.
require 'minitest/spec'
require 'minitest/autorun'

# You might want to put some debugging tools here.  We run tests to find bugs,
# after all.
require 'byebug'
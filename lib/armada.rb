# coding: UTF-8

require 'yajl'
require 'socket'

require 'active_model'
require 'active_support/core_ext/array/access'
require 'active_support/core_ext/array/uniq_by'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/module/attribute_accessors'

require 'armada/dirty'
require 'armada/errors'
require 'armada/relation'
require 'armada/callbacks'
require 'armada/observer'
require 'armada/timestamp'
require 'armada/connection'
require 'armada/validations'
require 'armada/finder_methods'
require 'armada/database_methods'
require 'armada/attribute_methods'

require 'armada/model'
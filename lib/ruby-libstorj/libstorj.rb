require 'rubygems'
require 'ffi'
require 'date'

module LibStorj
  # NB: not currently used but useful for debugging
  require 'ruby-libstorj/struct'
  require 'ruby-libstorj/ext/types'
  require 'ruby-libstorj/ext/json_request'
  require 'ruby-libstorj/ext/get_bucket_request'
  require 'ruby-libstorj/ext/create_bucket_request'
  require 'ruby-libstorj/ext/list_files_request'
  require 'ruby-libstorj/ext/bucket'
  require 'ruby-libstorj/ext/file'
  require 'ruby-libstorj/ext/ext'

  require 'ruby-libstorj/env'
  require 'ruby-libstorj/mixins/storj'

  extend ::LibStorj::Ext::Storj::Mixins

  def self.util_datetime
    # '%Q' - Number of milliseconds since 1970-01-01 00:00:00 UTC.
    DateTime.strptime(LibStorj.util_timestamp.to_s, '%Q')
  end

  # default to highest strength; strength range: (128..256)
  def self.mnemonic_generate(strength = 256)
    pointer = FFI::MemoryPointer.new :pointer, 1
    ::LibStorj::Ext::Storj.mnemonic_generate(strength, pointer)
    pointer.read_pointer.read_string
  end
end

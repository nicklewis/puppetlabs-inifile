Puppet::Type.newtype(:ini_setting) do

  def self.title_patterns
    identity = lambda {|x| x}
    strip_brackets = lambda{|x| x.gsub(/^\[|\]$/, '')}

    [
      [/^(\S+)\s+\[([^\]]+)\]\s+([^=]+?)\s*=(.+)$/m,
        [[:path,    identity],
         [:section, strip_brackets],
         [:setting, identity],
         [:value,   identity]]],
      [/^(\S+)\s+\[([^\]]+)\]\s+(\S+)$/m,
        [[:path,    identity],
         [:section, strip_brackets],
         [:setting, identity]]],
      [/^\[([^\]]+)\]\s+(\S+)$/m,
        [[:section, strip_brackets],
         [:setting, identity]]],
      [/^(\S+)$/m,
        [[:setting, identity]]],
    ]
  end

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:section) do
    desc 'The name of the section in the ini file in which the setting should be defined.'
  end

  newparam(:setting) do
    desc 'The name of the setting to be defined.'
  end

  newparam(:path) do
    desc 'The ini file Puppet will ensure contains the specified setting.'
    validate do |value|
      unless (Puppet.features.posix? and value =~ /^\//) or (Puppet.features.microsoft_windows? and (value =~ /^.:\// or value =~ /^\/\/[^\/]+\/[^\/]+/))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end

  newparam(:key_val_separator) do
    desc 'The separator string to use between each setting name and value. ' +
        'Defaults to " = ", but you could use this to override e.g. whether ' +
        'or not the separator should include whitespace.'
    defaultto(" = ")

    validate do |value|
      unless value.scan('=').size == 1
        raise Puppet::Error, ":key_val_separator must contain exactly one = character."
      end
    end
  end

  newproperty(:value) do
    desc 'The value of the setting to be defined.'
  end


end

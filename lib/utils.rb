require 'fileutils'

class Hash

  def slice(*keys)
    Hash[select { |k, v| keys.include?(k) }]
  end

  def to_opts
    opts = []
    self.collect do |key, value|
      opts << "--#{key.to_s.gsub('_', '-')}"
      opts << "#{value}"
    end
    opts
  end
end

def opts_to_hash(opts)
  internal = {}
  return internal if opts.empty?
  opts.split(' ').each do |key, value|
    internal[key.sub(/^[-]+/, '').gsub('-','_')] = value
  end
  internal
end

class Sequence

  attr_reader :value, :path

  def initialize(path)
    @path = File.expand_path(path)
    @value = 0
    @value = File.read(@path).to_i if File.exist?(@path)
  end

  def to_s
    @value.to_s
  end

  def next
    @value += 1
    store
    self
  end

  def store
    dir = File.dirname(@path)

    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end

    File.open(@path, 'w') { |f| f.write(@value.to_s) }
  end
end

require 'trollop'

module RVC

class OptionParser < Trollop::Parser
  def initialize cmd, &b
    @cmd = cmd
    @summary = nil
    @args = []
    @has_options = false
    @seen_not_required = false
    @seen_multi = false
    super &b
  end

  def summary str
    @summary = str
    text str
  end

  def summary?
    @summary
  end

  def opt name, *a
    super
    @has_options = true unless name == :help
  end

  def has_options?
    @has_options
  end

  def arg name, description, opts={}
    opts = {
      :required => true,
      :default => nil,
      :multi => false,
    }.merge opts
    opts[:default] = [] if opts[:multi] and opts[:default].nil?
    fail "Multi argument must be the last one" if @seen_multi
    fail "Can't have required argument after optional ones" if opts[:required] and @seen_not_required
    @args << [name, description, opts[:required], opts[:default], opts[:multi]]
    text "  #{name}: #{description}"
  end

  def parse argv
    opts = super argv
    argv = leftovers
    args = []
    @args.each do |name,desc,required,default,multi|
      if multi
        err "missing argument '#{name}'" if required and argv.empty?
        args << (argv.empty? ? default : argv.dup)
        argv.clear
      else
        x = argv.shift
        err "missing argument '#{name}'" if required and x.nil?
        x = default if x.nil?
        args << x
      end
    end
    err "too many arguments" unless argv.empty?
    return args, opts
  end

  def educate
    arg_texts = @args.map do |name,desc,required,default,multi|
      text = name
      text = "[#{text}]" if not required
      text = "#{text}..." if multi
      text
    end
    arg_texts.unshift "[opts]" if has_options?
    puts "usage: #{@cmd} #{arg_texts*' '}"
    super
  end
end

end
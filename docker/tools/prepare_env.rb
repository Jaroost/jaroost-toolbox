#!/usr/bin/env ruby
require 'dotenv'
require 'json'
require 'securerandom'
require 'slop'

# Parsing the arguments
parsed_opts = Slop.parse do |o|
  o.bool '-a', '--all', 'even already set variables'
  o.string '-o', '--output-file', 'output env file', default: '../.env'
  o.string '-i', '--input-file', 'current env file', default: '../../.env'
  o.string '-c', '--config-file', 'config file', default: './all_configs.json'
  o.string '-s', '--save-between', 'save between variables', default: 'false'
  o.on '-h', '--help' do
    puts o
    exit
  end
end

# Keeping only unparsed arguments
ARGV.replace parsed_opts.arguments

opts = parsed_opts.to_hash

Dotenv.load(opts[:input_file]) if File.exist?(opts[:input_file])


class String
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def brown;          "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end

class EnvOption
  attr_accessor :index, :value, :description
  def initialize(init_hash={})
    init_hash.transform_keys! {|k| k.to_sym }
    @value=init_hash[:value]
    @description=init_hash[:description]
    @index=init_hash[:index]
  end

  def puts_message
    ret=" - ".green
    ret+="[#{@index}]#{@value}".bold.black
    unless @description.nil?
      ret+=", #{@description}".green
    end
    ret+"\n"
  end
end

class EnvDefinition
  attr_accessor :service,:name, :forced_value, :options, :default, :description, :type, :value
  def initialize(init_hash={})
    init_hash.transform_keys! {|k| k.to_sym }
    @service=init_hash[:service].upcase
    @forced_value=init_hash[:forced_value]
    @type=init_hash[:type] || 'string'
    @description=init_hash[:description]
    @name=init_hash[:name]
    @options=[]
    if init_hash[:options]
      init_hash[:options].each_with_index do |option, index|
        @options<<EnvOption.new(option.merge(index: index))
      end
    end
    @default=ENV.fetch(@name, nil) || init_hash[:default]
      @value=ENV.fetch(@name, nil)
    unless @forced_value.nil?
      interpolated_forced_value = forced_value.gsub(/\$\{(.*?)\}/) do
        ENV.fetch($1, $1)
      end
      if interpolated_forced_value == @value
        # If the forced value interpolates to the same value, we de-interpolate it
        @value=@forced_value
      end
    end

  end

  def puts_message
    ret="[#{@service}] #{@name}\n".bold.brown
    ret+="#{@description}".green
    if @default
      ret+="[#{@default}]".bold.black
    end
    unless @options.empty?
      ret+="\n"
      @options.each do |option|
        ret+=option.puts_message
      end
    end
    ret+": (r=SecureRandom.hex)".bold.black
  end

  def is_editable?
    self.forced_value.nil?
  end

  def get_input_or_default(input)
    unless @options.empty?
      selected_option= @options.find{|option| option.index.to_s==input}
      if selected_option
        return selected_option.value
      end
    end
    if input=='' || input.nil?
      return @default
    end
    if input=='r'
      return SecureRandom.hex
    end
    input
  end

  def get_user_response
    if is_editable?
      input=nil
      loop do
        puts puts_message
        input=gets.strip
        input=get_input_or_default(input)
        break if is_valid_response?(input)
      end
      input
    else
      puts puts_message
      self.forced_value
    end
  end

  def is_valid_response?(response)
    if response=='' || response.nil?
      return false
    end

    unless is_editable?
      response==@forced_value
    end

    unless @options.empty?
      return !@options.select{|env_option| env_option.value==response}.empty?
    end

    case @type
    when "string"
      true
    when "boolean"
      response=="true" || response=="false"
    when "integer"
      response.to_i.to_s==response
    else
      false
    end
  end

  def response_value_message
    "Selected value is: ".gray.bold.+ @value.blue.bold
  end

  def env_line
    if @value
      "#[#{@service}] - #{@description}\n#{@name}=#{@value}\n"
    else
      nil
    end
  end
end

class EnvDefinitionContainer
  attr_accessor :env_definitions, :output_file
  def initialize(config_file, output_file)
    Dotenv.load(output_file) if File.exist?(output_file)
    @output_file=output_file
    @env_definitions=JSON.parse(File.read(config_file)).map{|hash|EnvDefinition.new(hash)}
  end

  def interactive_env_creation(all: false, save_between: false)
    env_definitions.each do |definition|
      if all || definition.value.nil?
        response=definition.get_user_response
        definition.value = response
        puts definition.response_value_message
      elsif (!definition.is_editable?) && definition.value != definition.forced_value
        definition.value = definition.get_user_response
        puts definition.response_value_message
      end
      write_file if save_between
    end
    write_file
  end

  def write_file
    File.open(@output_file, "w") do |file|
      file.write @env_definitions.map{|definition| definition.env_line}.join("\n")
    end
  end
end

container=EnvDefinitionContainer.new(opts[:config_file], opts[:output_file])
container.interactive_env_creation(all: opts[:all], save_between: opts[:'save-between'])
